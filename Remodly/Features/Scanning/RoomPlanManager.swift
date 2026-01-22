import Foundation
import RoomPlan
import Combine

@MainActor
class RoomPlanManager: NSObject, ObservableObject {
    @Published var isCapturing = false
    @Published var capturedRoom: CapturedRoom?
    @Published var qualityScore: Double = 0.0
    @Published var canFinish = false

    // Checklist state
    @Published var hasScannedPerimeter = false
    @Published var hasScannedOpenings = false
    @Published var hasScannedFixtures = false
    @Published var hasScannedCeiling = false

    // Summary stats
    @Published var wallCount = 0
    @Published var doorCount = 0
    @Published var windowCount = 0

    let captureSession: RoomCaptureSession

    override init() {
        self.captureSession = RoomCaptureSession()
        super.init()
        captureSession.delegate = self
    }

    func startCapture() {
        let config = RoomCaptureSession.Configuration()
        captureSession.run(configuration: config)
        isCapturing = true
    }

    func stopCapture() {
        captureSession.stop()
        isCapturing = false
    }

    func saveCapture(to url: URL) throws {
        guard let room = capturedRoom else {
            throw CaptureError.noData
        }

        // Export as USDZ
        try room.export(to: url, exportOptions: .parametric)
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

    func updateStats(from room: CapturedRoom) {
        wallCount = room.walls.count
        doorCount = room.doors.count
        windowCount = room.windows.count

        // Update checklist based on captured elements
        hasScannedPerimeter = room.walls.count >= 4
        hasScannedOpenings = room.doors.count > 0 || room.windows.count > 0
        hasScannedFixtures = !room.objects.isEmpty
        hasScannedCeiling = room.walls.contains { $0.dimensions.y > 2.0 } // Rough ceiling detection

        updateQualityScore()
    }
}

// MARK: - RoomCaptureSessionDelegate
extension RoomPlanManager: RoomCaptureSessionDelegate {
    nonisolated func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        Task { @MainActor in
            self.capturedRoom = room
            self.updateStats(from: room)
        }
    }

    nonisolated func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: Error?) {
        Task { @MainActor in
            if let error = error {
                print("Capture ended with error: \(error)")
            }
            // Process the captured data
            self.isCapturing = false
        }
    }

    nonisolated func captureSession(_ session: RoomCaptureSession, didProvide instruction: RoomCaptureSession.Instruction) {
        // Handle instructions (e.g., "Move closer", "Scan more area")
        Task { @MainActor in
            print("Instruction: \(instruction)")
        }
    }
}

enum CaptureError: Error {
    case noData
    case saveFailed
}
