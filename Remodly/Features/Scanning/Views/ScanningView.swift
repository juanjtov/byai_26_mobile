import SwiftUI
import RoomPlan
import Combine
import AVFoundation

struct ScanningView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scanState = ScanState()
    @State private var showResults = false
    @State private var cameraPermissionGranted = false
    @State private var permissionChecked = false
    @State private var isRoomPlanSupported = false
    @State private var roomPlanCheckComplete = false

    var body: some View {
        NavigationStack {
            ZStack {
                if !roomPlanCheckComplete || !permissionChecked {
                    // Loading state while checking device and permission
                    ProgressView("Checking device capabilities...")
                } else if !isRoomPlanSupported {
                    // Simulator/unsupported device fallback
                    unsupportedDeviceView
                } else if !cameraPermissionGranted {
                    // Permission denied view
                    permissionDeniedView
                } else {
                    // RoomPlan capture view
                    RoomCaptureViewContainer(scanState: scanState)
                        .ignoresSafeArea()

                    // Guidance overlay
                    VStack {
                        Spacer()

                        ScanGuidanceOverlay(scanState: scanState)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .padding()
                    }
                }
            }
            .navigationTitle("Scan Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        scanState.stopCapture()
                        dismiss()
                    }
                }

                if isRoomPlanSupported && cameraPermissionGranted {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            scanState.stopCapture()
                            showResults = true
                        }
                        .disabled(!scanState.canFinish)
                    }
                }
            }
            .sheet(isPresented: $showResults) {
                ScanResultView(scanState: scanState)
            }
            .onAppear {
                checkRoomPlanSupport()
                checkCameraPermission()
            }
        }
    }

    private var unsupportedDeviceView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(.secondary)

            Text("LiDAR Required")
                .font(.title2)
                .fontWeight(.bold)

            Text("Room scanning requires an iPhone or iPad with LiDAR sensor.\n\nThis feature is not available on the simulator.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("Show Demo Results") {
                showResults = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }

    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)

            Text("Camera Access Required")
                .font(.title2)
                .fontWeight(.bold)

            Text("Remodly needs camera access to scan rooms using LiDAR.\n\nPlease enable camera access in Settings.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }

    private func checkRoomPlanSupport() {
        // Defer RoomPlan availability check to avoid crash on launch
        Task { @MainActor in
            // Small delay to ensure view is fully loaded
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

            // Check RoomPlan support on main actor
            let supported = RoomCaptureSession.isSupported
            isRoomPlanSupported = supported
            roomPlanCheckComplete = true
        }
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
            permissionChecked = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionGranted = granted
                    permissionChecked = true
                }
            }
        case .denied, .restricted:
            cameraPermissionGranted = false
            permissionChecked = true
        @unknown default:
            cameraPermissionGranted = false
            permissionChecked = true
        }
    }
}

// Observable state for scan progress
@MainActor
class ScanState: ObservableObject {
    @Published var isCapturing = false
    @Published var capturedRoom: CapturedRoom?
    @Published var qualityScore: Double = 0.0
    @Published var canFinish = false
    @Published var hasScannedPerimeter = false
    @Published var hasScannedOpenings = false
    @Published var hasScannedFixtures = false
    @Published var hasScannedCeiling = false
    @Published var wallCount = 0
    @Published var doorCount = 0
    @Published var windowCount = 0

    weak var captureView: RoomCaptureView?

    func startCapture() {
        guard !isCapturing else { return }
        isCapturing = true
        let config = RoomCaptureSession.Configuration()
        captureView?.captureSession.run(configuration: config)
    }

    func stopCapture() {
        guard isCapturing else { return }
        captureView?.captureSession.stop()
        isCapturing = false
    }

    func updateStats(from room: CapturedRoom) {
        capturedRoom = room
        wallCount = room.walls.count
        doorCount = room.doors.count
        windowCount = room.windows.count

        hasScannedPerimeter = room.walls.count >= 4
        hasScannedOpenings = room.doors.count > 0 || room.windows.count > 0
        hasScannedFixtures = !room.objects.isEmpty
        hasScannedCeiling = room.walls.contains { $0.dimensions.y > 2.0 }

        updateQualityScore()
    }

    private func updateQualityScore() {
        var score = 0.0
        if hasScannedPerimeter { score += 0.25 }
        if hasScannedOpenings { score += 0.25 }
        if hasScannedFixtures { score += 0.25 }
        if hasScannedCeiling { score += 0.25 }
        qualityScore = score
        canFinish = score >= Constants.Scan.minimumQualityScore
    }
}

// Coordinator class for RoomPlan delegates - must be at top level for NSCoding
class RoomCaptureCoordinator: NSObject, RoomCaptureSessionDelegate, RoomCaptureViewDelegate, NSCoding {
    let scanState: ScanState

    init(scanState: ScanState) {
        self.scanState = scanState
    }

    // NSCoding conformance (required by RoomCaptureViewDelegate)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    func encode(with coder: NSCoder) {
        // Not used
    }

    // MARK: - RoomCaptureSessionDelegate
    func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        Task { @MainActor in
            scanState.updateStats(from: room)
        }
    }

    func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: Error?) {
        Task { @MainActor in
            if let error = error {
                print("Capture ended with error: \(error)")
            }
            scanState.isCapturing = false
        }
    }

    func captureSession(_ session: RoomCaptureSession, didProvide instruction: RoomCaptureSession.Instruction) {
        print("Instruction: \(instruction)")
    }

    // MARK: - RoomCaptureViewDelegate
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }

    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        Task { @MainActor in
            if let error = error {
                print("Processing error: \(error)")
            }
            scanState.capturedRoom = processedResult
        }
    }
}

// UIViewRepresentable for RoomCaptureView
@available(iOS 17.0, *)
struct RoomCaptureViewContainer: UIViewRepresentable {
    @ObservedObject var scanState: ScanState

    func makeUIView(context: Context) -> RoomCaptureView {
        let view = RoomCaptureView()

        // Configure delegates
        view.captureSession.delegate = context.coordinator
        view.delegate = context.coordinator

        // Store reference and start capture immediately
        Task { @MainActor in
            scanState.captureView = view
            scanState.startCapture()
        }

        return view
    }

    func updateUIView(_ uiView: RoomCaptureView, context: Context) {}

    func makeCoordinator() -> RoomCaptureCoordinator {
        RoomCaptureCoordinator(scanState: scanState)
    }
}

// Simplified guidance overlay that uses ScanState
struct ScanGuidanceOverlay: View {
    @ObservedObject var scanState: ScanState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Scan Checklist")
                .font(.headline)

            ChecklistItem(
                title: "Scan full perimeter",
                isCompleted: scanState.hasScannedPerimeter,
                icon: "arrow.triangle.2.circlepath"
            )

            ChecklistItem(
                title: "Capture openings",
                isCompleted: scanState.hasScannedOpenings,
                icon: "door.left.hand.open"
            )

            ChecklistItem(
                title: "Capture fixtures",
                isCompleted: scanState.hasScannedFixtures,
                icon: "sink"
            )

            ChecklistItem(
                title: "Capture ceiling",
                isCompleted: scanState.hasScannedCeiling,
                icon: "rectangle.compress.vertical"
            )

            HStack {
                Text("Scan Quality:")
                    .font(.subheadline)
                Spacer()
                QualityIndicator(score: scanState.qualityScore)
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    ScanningView()
}
