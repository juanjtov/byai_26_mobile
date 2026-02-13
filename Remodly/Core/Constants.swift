import Foundation

enum Constants {
    enum Scan {
        static let minimumQualityScore: Double = 0.7
        static let snapshotCameraAngles = ["entry_corner", "opposite_corner", "vanity", "shower_tub"]
    }

    enum Storage {
        static let authTokenKey = "auth_token"
        static let organizationIdKey = "organization_id"
        static let userIdKey = "user_id"
        static let snapshotDirectoryName = "design_snapshots"
    }

    enum Performance {
        static let quantitySheetTimeoutSeconds: Double = 10
        static let styleToggleTimeoutSeconds: Double = 2
        static let snapshotRenderTimeoutSeconds: Double = 20
        static let estimateGenerationTimeoutSeconds: Double = 15
    }
}
