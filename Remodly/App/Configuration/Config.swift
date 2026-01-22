import Foundation

enum Config {
    enum API {
        static var baseURL: String {
            #if DEBUG
            return "https://api-dev.remodly.com"
            #else
            return "https://api.remodly.com"
            #endif
        }
    }

    enum App {
        static let bundleIdentifier = "com.remodly.mobile"
        static let appName = "Remodly"
    }
}
