import Foundation

enum Config: Sendable {
    enum API: Sendable {
        nonisolated(unsafe) static let baseURL: String = {
            #if DEBUG
            return "https://api-dev.remodly.com"
            #else
            return "https://api.remodly.com"
            #endif
        }()
    }

    enum App {
        static let bundleIdentifier = "com.remodly.mobile"
        static let appName = "Remodly"
    }
}
