import Foundation
import Network
import Combine

@MainActor
class SyncService: ObservableObject {
    static let shared = SyncService()

    @Published var isOnline = true
    @Published var pendingUploads: [PendingUpload] = []

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        startMonitoring()
        loadPendingUploads()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = path.status == .satisfied
                if path.status == .satisfied {
                    await self?.processPendingUploads()
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    func queueUpload(_ upload: PendingUpload) {
        pendingUploads.append(upload)
        savePendingUploads()

        if isOnline {
            Task {
                await processPendingUploads()
            }
        }
    }

    private func processPendingUploads() async {
        guard isOnline else { return }

        for upload in pendingUploads {
            do {
                try await processUpload(upload)
                pendingUploads.removeAll { $0.id == upload.id }
                savePendingUploads()
            } catch {
                print("Failed to process upload \(upload.id): \(error)")
            }
        }
    }

    private func processUpload(_ upload: PendingUpload) async throws {
        guard let fileURL = URL(string: upload.localFilePath) else {
            throw SyncError.invalidFilePath
        }

        switch upload.type {
        case .roomCapture:
            let _: UploadResponse = try await APIClient.shared.upload(
                endpoint: .roomCaptureComplete(visitId: upload.referenceId),
                fileURL: fileURL,
                mimeType: "application/octet-stream"
            )
        case .snapshot:
            // Handle snapshot upload
            break
        }
    }

    private func savePendingUploads() {
        if let data = try? JSONEncoder().encode(pendingUploads) {
            UserDefaults.standard.set(data, forKey: "pending_uploads")
        }
    }

    private func loadPendingUploads() {
        if let data = UserDefaults.standard.data(forKey: "pending_uploads"),
           let uploads = try? JSONDecoder().decode([PendingUpload].self, from: data) {
            pendingUploads = uploads
        }
    }
}

struct PendingUpload: Codable, Identifiable {
    let id: String
    let type: UploadType
    let localFilePath: String
    let referenceId: String
    let createdAt: Date

    enum UploadType: String, Codable {
        case roomCapture
        case snapshot
    }
}

enum SyncError: Error {
    case invalidFilePath
    case uploadFailed
}
