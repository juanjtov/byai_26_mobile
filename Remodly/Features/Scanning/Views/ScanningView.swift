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

    // Room type selection flow
    @State private var selectedRoomType: RoomCapture.RoomType?
    @State private var showRoomTypeSelection = true

    var body: some View {
        NavigationStack {
            ZStack {
                if showRoomTypeSelection {
                    // Step 1: Room type selection
                    RoomTypeSelectionView(
                        selectedRoomType: $selectedRoomType
                    ) {
                        if let roomType = selectedRoomType {
                            scanState.roomType = roomType
                            showRoomTypeSelection = false
                        }
                    }
                } else if !roomPlanCheckComplete || !permissionChecked {
                    // Loading state while checking device and permission
                    ProgressView("Checking device capabilities...")
                } else if !isRoomPlanSupported {
                    // Simulator/unsupported device fallback
                    unsupportedDeviceView
                } else if !cameraPermissionGranted {
                    // Permission denied view
                    permissionDeniedView
                } else {
                    // Step 2: Active scanning
                    ZStack {
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

                        // Large room guidance popup
                        if scanState.isLargeRoomDetected {
                            Color.black.opacity(0.5)
                                .ignoresSafeArea()

                            LargeRoomGuidanceView {
                                scanState.dismissLargeRoomGuidance()
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle(showRoomTypeSelection ? "Select Room Type" : "Scan Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Dismiss any open modal sheets first
                        scanState.showNoOpeningsConfirmation = false
                        scanState.isLargeRoomDetected = false

                        // Stop capture
                        scanState.stopCapture()

                        // Dismiss the view
                        dismiss()
                    }
                }

                if !showRoomTypeSelection && isRoomPlanSupported && cameraPermissionGranted {
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
            .sheet(isPresented: $scanState.showNoOpeningsConfirmation) {
                NoOpeningsConfirmationSheet(
                    roomType: scanState.roomType,
                    onConfirm: {
                        scanState.confirmNoOpenings()
                    },
                    onContinueScanning: {
                        scanState.showNoOpeningsConfirmation = false
                    }
                )
                .presentationDetents([.medium])
            }
            .onAppear {
                if !showRoomTypeSelection {
                    checkRoomPlanSupport()
                    checkCameraPermission()
                }
            }
            .onChange(of: showRoomTypeSelection) { _, showing in
                if !showing {
                    checkRoomPlanSupport()
                    checkCameraPermission()
                }
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

    // Room type context
    @Published var roomType: RoomCapture.RoomType = .bathroom
    @Published var hasConfirmedNoOpenings = false
    @Published var estimatedRoomSize: ScanQualityConfiguration.RoomSize = .medium
    @Published var showNoOpeningsConfirmation = false

    // Large room guidance
    @Published var isLargeRoomDetected = false
    @Published var largeRoomGuidanceShown = false

    weak var captureView: RoomCaptureView?

    private var qualityConfig: ScanQualityConfiguration {
        ScanQualityConfiguration(
            roomType: roomType,
            estimatedRoomSize: estimatedRoomSize,
            hasConfirmedNoOpenings: hasConfirmedNoOpenings
        )
    }

    func startCapture() {
        guard !isCapturing else { return }
        isCapturing = true
        let config = RoomCaptureSession.Configuration()
        captureView?.captureSession.run(configuration: config)
    }

    func stopCapture() {
        // Always set isCapturing to false, even if captureView is nil
        isCapturing = false

        // Stop the capture session if available
        captureView?.captureSession.stop()

        // Reset any modal states that might block dismiss
        showNoOpeningsConfirmation = false
        isLargeRoomDetected = false
    }

    func updateStats(from room: CapturedRoom) {
        capturedRoom = room
        wallCount = room.walls.count
        doorCount = room.doors.count
        windowCount = room.windows.count

        // Estimate room size from floor area
        estimateRoomSize(from: room)

        // Update checklist with room-type awareness
        hasScannedPerimeter = room.walls.count >= 4

        // For rooms that typically lack openings, auto-complete or prompt
        if roomType.typicallyHasWindows && !hasConfirmedNoOpenings {
            hasScannedOpenings = room.doors.count > 0 || room.windows.count > 0
        } else {
            // For utility/bathroom: openings optional, prompt if none found after perimeter
            hasScannedOpenings = hasConfirmedNoOpenings || room.doors.count > 0 || room.windows.count > 0

            // Prompt user if perimeter complete but no openings
            if hasScannedPerimeter && !hasScannedOpenings && !showNoOpeningsConfirmation && !hasConfirmedNoOpenings {
                showNoOpeningsConfirmation = true
            }
        }

        hasScannedFixtures = !room.objects.isEmpty
        hasScannedCeiling = room.walls.contains { $0.dimensions.y > 2.0 }

        updateQualityScore()
    }

    private func estimateRoomSize(from room: CapturedRoom) {
        // Need at least 4 walls for reliable floor area calculation
        guard room.walls.count >= 4 else { return }

        let measurements = MeasurementExtractor.extract(from: room)
        let floorArea = measurements.floorArea

        // Validate floor area is reasonable (not NaN, not zero, not unrealistically huge)
        guard floorArea.isFinite && floorArea > 0 && floorArea < 10000 else { return }

        let newSize = ScanQualityConfiguration.roomSize(fromFloorArea: floorArea)

        if newSize != estimatedRoomSize {
            estimatedRoomSize = newSize

            // Show large room guidance if detected for the first time
            if newSize == .large && !largeRoomGuidanceShown {
                isLargeRoomDetected = true
            }
        }
    }

    private func updateQualityScore() {
        let weights = qualityConfig.qualityWeights.normalized
        var score = 0.0

        if hasScannedPerimeter { score += weights.perimeterWeight }
        if hasScannedOpenings { score += weights.openingsWeight }
        if hasScannedFixtures { score += weights.fixturesWeight }
        if hasScannedCeiling { score += weights.ceilingWeight }

        qualityScore = score
        canFinish = score >= qualityConfig.minimumQualityScore
    }

    /// Called when user confirms no openings in this room
    func confirmNoOpenings() {
        hasConfirmedNoOpenings = true
        showNoOpeningsConfirmation = false
        hasScannedOpenings = true
        updateQualityScore()
    }

    /// Called when user dismisses large room guidance
    func dismissLargeRoomGuidance() {
        largeRoomGuidanceShown = true
        isLargeRoomDetected = false
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

        // Store reference and start capture synchronously
        // This ensures captureView is available immediately for cancel to work
        scanState.captureView = view
        scanState.startCapture()

        return view
    }

    func updateUIView(_ uiView: RoomCaptureView, context: Context) {}

    func makeCoordinator() -> RoomCaptureCoordinator {
        RoomCaptureCoordinator(scanState: scanState)
    }
}

// Room-type-aware guidance overlay
struct ScanGuidanceOverlay: View {
    @ObservedObject var scanState: ScanState

    private var roomType: RoomCapture.RoomType {
        scanState.roomType
    }

    private var showOpeningsItem: Bool {
        // Show openings item if room typically has windows and user hasn't confirmed no openings
        roomType.typicallyHasWindows && !scanState.hasConfirmedNoOpenings
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Room type indicator
            HStack {
                Image(systemName: roomType.icon)
                    .foregroundColor(.copper)
                Text(roomType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // Room size indicator for large rooms
                if scanState.estimatedRoomSize == .large {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left.and.right")
                            .font(.caption)
                        Text("Large")
                            .font(.caption)
                    }
                    .foregroundColor(.gold)
                }
            }

            Text("Scan Checklist")
                .font(.headline)

            ChecklistItem(
                title: "Scan full perimeter",
                isCompleted: scanState.hasScannedPerimeter,
                icon: "arrow.triangle.2.circlepath"
            )

            // Conditional openings checklist item
            if showOpeningsItem {
                ChecklistItem(
                    title: "Capture openings",
                    isCompleted: scanState.hasScannedOpenings,
                    icon: "door.left.hand.open"
                )
            } else if scanState.hasConfirmedNoOpenings {
                ChecklistItem(
                    title: "No openings (confirmed)",
                    isCompleted: true,
                    icon: "window.ceiling.closed"
                )
            }

            // Room-type-specific fixture label
            ChecklistItem(
                title: fixtureLabel,
                isCompleted: scanState.hasScannedFixtures,
                icon: fixtureIcon
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

    private var fixtureLabel: String {
        switch roomType {
        case .bathroom: return "Capture fixtures"
        case .kitchen: return "Capture appliances"
        case .utility: return "Capture appliances"
        default: return "Capture objects"
        }
    }

    private var fixtureIcon: String {
        switch roomType {
        case .bathroom: return "sink"
        case .kitchen: return "refrigerator"
        case .utility: return "washer"
        default: return "cube"
        }
    }
}

#Preview {
    ScanningView()
}
