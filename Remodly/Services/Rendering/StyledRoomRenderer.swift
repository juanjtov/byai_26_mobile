import Foundation
import RealityKit
import RoomPlan
import UIKit
import simd

// MARK: - Rendering Error

enum RenderingError: Error, LocalizedError {
    case snapshotCaptureFailed
    case imageEncodingFailed
    case invalidRoomData

    var errorDescription: String? {
        switch self {
        case .snapshotCaptureFailed: return "Failed to capture snapshot from renderer"
        case .imageEncodingFailed: return "Failed to encode snapshot image"
        case .invalidRoomData: return "Room data is invalid for rendering"
        }
    }
}

// MARK: - Style Color Mapping

/// Maps a StylePreset to concrete colors for each room element
struct StyleColorMapping {
    let wallColor: UIColor
    let doorColor: UIColor
    let windowColor: UIColor
    let floorColor: UIColor
    let ceilingColor: UIColor
    let cabinetColor: UIColor
    let applianceColor: UIColor
    let sinkColor: UIColor
    let backgroundColor: UIColor

    // Material properties per style
    let wallMetallic: Float
    let wallRoughness: Float
    let cabinetMetallic: Float
    let cabinetRoughness: Float
    let applianceMetallic: Float
    let applianceRoughness: Float

    static func from(style: StylePreset) -> StyleColorMapping {
        let primary = UIColor(hex: style.palette.primary)
        let secondary = UIColor(hex: style.palette.secondary)
        let accent = UIColor(hex: style.palette.accent)
        let neutral = UIColor(hex: style.palette.neutral)

        switch style.fixtureStyleDirection {
        case "modern": // Sophisticated
            return StyleColorMapping(
                wallColor: primary.withAlphaComponent(0.85),
                doorColor: accent.withAlphaComponent(0.8),
                windowColor: secondary.withAlphaComponent(0.5),
                floorColor: neutral.withAlphaComponent(0.7),
                ceilingColor: secondary.withAlphaComponent(0.4),
                cabinetColor: UIColor(hex: "#ECF0F1").withAlphaComponent(0.9),
                applianceColor: UIColor(hex: "#C0C0C0").withAlphaComponent(0.9),
                sinkColor: UIColor(hex: "#C0C0C0").withAlphaComponent(0.9),
                backgroundColor: neutral.withAlphaComponent(0.3),
                wallMetallic: 0.15,
                wallRoughness: 0.7,
                cabinetMetallic: 0.6,
                cabinetRoughness: 0.3,
                applianceMetallic: 0.6,
                applianceRoughness: 0.3
            )

        case "traditional": // Antique
            return StyleColorMapping(
                wallColor: primary.withAlphaComponent(0.85),
                doorColor: accent.withAlphaComponent(0.8),
                windowColor: secondary.withAlphaComponent(0.5),
                floorColor: neutral.withAlphaComponent(0.7),
                ceilingColor: secondary.withAlphaComponent(0.4),
                cabinetColor: UIColor(hex: "#8B4513").withAlphaComponent(0.9),
                applianceColor: UIColor(hex: "#614126").withAlphaComponent(0.9),
                sinkColor: UIColor(hex: "#C0C0C0").withAlphaComponent(0.9),
                backgroundColor: neutral.withAlphaComponent(0.3),
                wallMetallic: 0.05,
                wallRoughness: 0.9,
                cabinetMetallic: 0.3,
                cabinetRoughness: 0.7,
                applianceMetallic: 0.3,
                applianceRoughness: 0.7
            )

        default: // European / transitional
            return StyleColorMapping(
                wallColor: primary.withAlphaComponent(0.85),
                doorColor: accent.withAlphaComponent(0.8),
                windowColor: secondary.withAlphaComponent(0.5),
                floorColor: neutral.withAlphaComponent(0.7),
                ceilingColor: secondary.withAlphaComponent(0.4),
                cabinetColor: UIColor(hex: "#E8E4E1").withAlphaComponent(0.9),
                applianceColor: UIColor(hex: "#808080").withAlphaComponent(0.9),
                sinkColor: UIColor(hex: "#C0C0C0").withAlphaComponent(0.9),
                backgroundColor: neutral.withAlphaComponent(0.3),
                wallMetallic: 0.10,
                wallRoughness: 0.8,
                cabinetMetallic: 0.4,
                cabinetRoughness: 0.5,
                applianceMetallic: 0.4,
                applianceRoughness: 0.5
            )
        }
    }
}

// MARK: - Styled Room Renderer

/// Renders a CapturedRoom with a StylePreset applied and captures snapshots
/// from multiple camera angles.
@MainActor
class StyledRoomRenderer {
    let room: CapturedRoom
    let style: StylePreset
    let colorMapping: StyleColorMapping

    private var arView: ARView?
    private var sceneAnchors: [AnchorEntity] = []

    init(room: CapturedRoom, style: StylePreset) {
        self.room = room
        self.style = style
        self.colorMapping = StyleColorMapping.from(style: style)
    }

    /// Renders all 4 camera angles and returns DesignSnapshot objects with saved images
    func renderAllAngles() async throws -> [DesignSnapshot] {
        guard !room.walls.isEmpty else {
            throw RenderingError.invalidRoomData
        }

        // 1. Setup offscreen ARView
        let arView = createStyledARView()
        self.arView = arView

        // 2. Build styled room geometry
        let center = calculateRoomCenter()
        let roomAnchor = createStyledRoomAnchor(center: center)
        arView.scene.addAnchor(roomAnchor)
        sceneAnchors.append(roomAnchor)

        // 3. Apply styled lighting
        let lightAnchor = createStyledLighting(center: center)
        arView.scene.addAnchor(lightAnchor)
        sceneAnchors.append(lightAnchor)

        // 4. Wait for scene to settle
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2s

        // 5. Capture snapshots from each angle
        var snapshots: [DesignSnapshot] = []
        let roomCaptureId = UUID().uuidString
        let storage = SnapshotStorageService.shared

        for angle in DesignSnapshot.CameraAngle.allCases {
            // Position camera for this angle
            let cameraAnchor = positionCamera(angle: angle, center: center)
            arView.scene.addAnchor(cameraAnchor)
            sceneAnchors.append(cameraAnchor)

            // Wait for rendering
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3s

            // Capture snapshot
            let image = try await captureSnapshot(from: arView)

            // Remove this camera anchor (will add new one for next angle)
            arView.scene.removeAnchor(cameraAnchor)
            sceneAnchors.removeAll { $0 === cameraAnchor }

            // Save to disk
            let fileName = "\(style.id)_\(angle.rawValue)_\(Int(Date().timeIntervalSince1970)).jpg"
            let filePath = try storage.saveImage(image, name: fileName)

            let snapshot = DesignSnapshot(
                id: UUID().uuidString,
                roomCaptureId: roomCaptureId,
                stylePresetId: style.id,
                cameraAngle: angle,
                localFilePath: filePath,
                serverUrl: nil,
                isUploaded: false,
                renderedAt: Date()
            )
            snapshots.append(snapshot)
        }

        // 6. Cleanup
        cleanup()

        return snapshots
    }

    // MARK: - ARView Setup

    private func createStyledARView() -> ARView {
        let arView = ARView(frame: CGRect(x: 0, y: 0, width: 1080, height: 1920))
        arView.cameraMode = .nonAR
        arView.environment.background = .color(colorMapping.backgroundColor)
        return arView
    }

    // MARK: - Room Geometry Construction

    private func calculateRoomCenter() -> simd_float3 {
        guard !room.walls.isEmpty else { return .zero }
        var sumPosition = simd_float3.zero
        for wall in room.walls {
            let position = simd_float3(
                wall.transform.columns.3.x,
                wall.transform.columns.3.y,
                wall.transform.columns.3.z
            )
            sumPosition += position
        }
        return sumPosition / Float(room.walls.count)
    }

    private func calculateRoomExtent() -> Float {
        guard !room.walls.isEmpty else { return 5.0 }
        var minX: Float = .greatestFiniteMagnitude
        var maxX: Float = -.greatestFiniteMagnitude
        var minZ: Float = .greatestFiniteMagnitude
        var maxZ: Float = -.greatestFiniteMagnitude

        for wall in room.walls {
            let x = wall.transform.columns.3.x
            let z = wall.transform.columns.3.z
            minX = min(minX, x)
            maxX = max(maxX, x)
            minZ = min(minZ, z)
            maxZ = max(maxZ, z)
        }

        let extentX = maxX - minX
        let extentZ = maxZ - minZ
        return max(extentX, extentZ, 3.0)
    }

    private func createStyledRoomAnchor(center: simd_float3) -> AnchorEntity {
        let anchor = AnchorEntity(world: .zero)

        // Walls
        for wall in room.walls {
            if let entity = createSurfaceEntity(
                surface: wall,
                roomCenter: center,
                color: colorMapping.wallColor,
                depth: 0.05,
                metallic: colorMapping.wallMetallic,
                roughness: colorMapping.wallRoughness
            ) {
                anchor.addChild(entity)
            }
        }

        // Doors
        for door in room.doors {
            if let entity = createSurfaceEntity(
                surface: door,
                roomCenter: center,
                color: colorMapping.doorColor,
                depth: 0.08,
                metallic: 0.2,
                roughness: 0.6
            ) {
                anchor.addChild(entity)
            }
        }

        // Windows
        for window in room.windows {
            if let entity = createSurfaceEntity(
                surface: window,
                roomCenter: center,
                color: colorMapping.windowColor,
                depth: 0.06,
                metallic: 0.4,
                roughness: 0.2
            ) {
                anchor.addChild(entity)
            }
        }

        // Floor
        anchor.addChild(createFloorEntity(center: center))

        // Ceiling
        anchor.addChild(createCeilingEntity(center: center))

        // Detected objects (cabinets + appliances)
        for object in room.objects {
            if let entity = createObjectEntity(object: object, roomCenter: center) {
                anchor.addChild(entity)
            }
        }

        return anchor
    }

    // MARK: - Entity Creation

    private func createSurfaceEntity(
        surface: CapturedRoom.Surface,
        roomCenter: simd_float3,
        color: UIColor,
        depth: Float,
        metallic: Float,
        roughness: Float
    ) -> ModelEntity? {
        guard isValidSurface(surface) else { return nil }

        let mesh = MeshResource.generateBox(
            width: surface.dimensions.x,
            height: surface.dimensions.y,
            depth: depth,
            cornerRadius: 0
        )

        var material = SimpleMaterial()
        material.color = .init(tint: color)
        material.metallic = .float(metallic)
        material.roughness = .float(roughness)

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = safePosition(from: surface.transform, relativeTo: roomCenter)
        entity.orientation = safeQuaternion(from: surface.transform)
        return entity
    }

    private func createObjectEntity(object: CapturedRoom.Object, roomCenter: simd_float3) -> ModelEntity? {
        let dims = object.dimensions
        guard dims.x > 0.01 && dims.y > 0.01 && dims.z > 0.01 else { return nil }

        // Determine color and material based on object category
        let (color, metallic, roughness) = colorForObject(category: object.category)
        guard let color = color else { return nil } // Skip unrecognized objects

        let mesh = MeshResource.generateBox(
            width: dims.x,
            height: dims.y,
            depth: dims.z,
            cornerRadius: 0
        )

        var material = SimpleMaterial()
        material.color = .init(tint: color)
        material.metallic = .float(metallic)
        material.roughness = .float(roughness)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position relative to room center
        let pos = object.transform.columns.3
        guard pos.x.isFinite && pos.y.isFinite && pos.z.isFinite else { return nil }
        entity.position = simd_float3(pos.x - roomCenter.x, pos.y - roomCenter.y, pos.z - roomCenter.z)
        entity.orientation = safeQuaternion(from: object.transform)

        return entity
    }

    private func colorForObject(category: CapturedRoom.Object.Category) -> (UIColor?, Float, Float) {
        switch category {
        // Cabinets / vanity
        case .storage:
            return (colorMapping.cabinetColor, colorMapping.cabinetMetallic, colorMapping.cabinetRoughness)

        // Kitchen appliances
        case .refrigerator, .stove, .dishwasher:
            return (colorMapping.applianceColor, colorMapping.applianceMetallic, colorMapping.applianceRoughness)

        // Sinks
        case .sink:
            return (colorMapping.sinkColor, 0.7, 0.2)

        // Bathroom fixtures
        case .toilet:
            return (UIColor.white.withAlphaComponent(0.9), 0.3, 0.4)
        case .bathtub:
            return (UIColor.white.withAlphaComponent(0.85), 0.2, 0.5)

        default:
            return (nil, 0, 0) // Skip unrecognized
        }
    }

    private func createFloorEntity(center: simd_float3) -> ModelEntity {
        let extent = calculateRoomExtent()
        let floorSize = max(extent * 1.2, 3.0)
        let mesh = MeshResource.generatePlane(width: floorSize, depth: floorSize)

        var material = SimpleMaterial()
        material.color = .init(tint: colorMapping.floorColor)
        material.metallic = .float(0.0)
        material.roughness = .float(0.9)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position floor at bottom of room
        let lowestY = room.walls.map { $0.transform.columns.3.y - $0.dimensions.y / 2 }.min() ?? 0
        entity.position = simd_float3(0, lowestY - center.y - 0.01, 0)

        return entity
    }

    private func createCeilingEntity(center: simd_float3) -> ModelEntity {
        let extent = calculateRoomExtent()
        let ceilingSize = max(extent * 1.2, 3.0)
        let mesh = MeshResource.generatePlane(width: ceilingSize, depth: ceilingSize)

        var material = SimpleMaterial()
        material.color = .init(tint: colorMapping.ceilingColor)
        material.metallic = .float(0.0)
        material.roughness = .float(1.0)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position ceiling at top of room
        let highestY = room.walls.map { $0.transform.columns.3.y + $0.dimensions.y / 2 }.max() ?? 2.5
        entity.position = simd_float3(0, highestY - center.y + 0.01, 0)
        // Flip ceiling to face down
        entity.orientation = simd_quatf(angle: .pi, axis: simd_float3(1, 0, 0))

        return entity
    }

    // MARK: - Lighting

    private func createStyledLighting(center: simd_float3) -> AnchorEntity {
        let lightAnchor = AnchorEntity(world: .zero)

        switch style.lightingPreset {
        case "bright_neutral": // Sophisticated
            let main = DirectionalLight()
            main.light.intensity = 1200
            main.light.color = .white
            main.position = simd_float3(2, 5, 2)
            main.look(at: .zero, from: main.position, relativeTo: nil)
            lightAnchor.addChild(main)

            let fill = DirectionalLight()
            fill.light.intensity = 600
            fill.light.color = UIColor(white: 0.95, alpha: 1.0)
            fill.position = simd_float3(-2, 3, -1)
            fill.look(at: .zero, from: fill.position, relativeTo: nil)
            lightAnchor.addChild(fill)

        case "warm_ambient": // Antique
            let main = DirectionalLight()
            main.light.intensity = 800
            main.light.color = UIColor(red: 1.0, green: 0.92, blue: 0.78, alpha: 1.0)
            main.position = simd_float3(1, 4, 2)
            main.look(at: .zero, from: main.position, relativeTo: nil)
            lightAnchor.addChild(main)

            let ambient = PointLight()
            ambient.light.intensity = 400
            ambient.light.color = UIColor(red: 1.0, green: 0.85, blue: 0.65, alpha: 1.0)
            ambient.position = simd_float3(0, 3, 0)
            lightAnchor.addChild(ambient)

        case "soft_directional": // European
            let main = DirectionalLight()
            main.light.intensity = 1000
            main.light.color = UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0)
            main.position = simd_float3(3, 5, 1)
            main.look(at: .zero, from: main.position, relativeTo: nil)
            lightAnchor.addChild(main)

            let fill = DirectionalLight()
            fill.light.intensity = 400
            fill.light.color = UIColor(white: 0.9, alpha: 1.0)
            fill.position = simd_float3(-1, 3, -2)
            fill.look(at: .zero, from: fill.position, relativeTo: nil)
            lightAnchor.addChild(fill)

        default:
            let light = DirectionalLight()
            light.light.intensity = 1000
            light.light.color = .white
            light.position = simd_float3(2, 5, 2)
            light.look(at: .zero, from: light.position, relativeTo: nil)
            lightAnchor.addChild(light)
        }

        return lightAnchor
    }

    // MARK: - Camera Positioning

    private func positionCamera(angle: DesignSnapshot.CameraAngle, center: simd_float3) -> AnchorEntity {
        let camera = PerspectiveCamera()
        camera.camera.fieldOfViewInDegrees = 60

        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)

        let roomExtent = calculateRoomExtent()
        let baseDistance = max(roomExtent, 5.0)

        // Spherical coordinates per angle
        let (distance, yaw, pitch): (Float, Float, Float) = {
            switch angle {
            case .entryCorner:
                return (baseDistance * 0.9, Float.pi * 0.25, 0.45)
            case .oppositeCorner:
                return (baseDistance * 0.9, Float.pi * 1.25, 0.45)
            case .vanity:
                return (baseDistance * 0.7, Float.pi * 0.75, 0.3)
            case .showerTub:
                return (baseDistance * 0.7, Float.pi * 1.75, 0.35)
            }
        }()

        let x = distance * cos(pitch) * sin(yaw)
        let y = distance * sin(pitch) + 1.5
        let z = distance * cos(pitch) * cos(yaw)

        camera.position = simd_float3(x, y, z)
        camera.look(at: simd_float3(0, 1, 0), from: camera.position, relativeTo: nil)

        return cameraAnchor
    }

    // MARK: - Snapshot Capture

    private func captureSnapshot(from arView: ARView) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            arView.snapshot(saveToHDR: false) { image in
                if let image = image {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: RenderingError.snapshotCaptureFailed)
                }
            }
        }
    }

    // MARK: - Cleanup

    private func cleanup() {
        if let arView = arView {
            for anchor in sceneAnchors {
                arView.scene.removeAnchor(anchor)
            }
        }
        sceneAnchors.removeAll()
        arView = nil
    }

    // MARK: - Validation Helpers (matching Room3DViewContainer patterns)

    private func isValidSurface(_ surface: CapturedRoom.Surface) -> Bool {
        isValidDimension(surface.dimensions.x) && isValidDimension(surface.dimensions.y)
    }

    private func isValidDimension(_ value: Float) -> Bool {
        value.isFinite && value > 0.001
    }

    private func safePosition(from transform: simd_float4x4, relativeTo center: simd_float3) -> simd_float3 {
        let x = transform.columns.3.x
        let y = transform.columns.3.y
        let z = transform.columns.3.z
        guard x.isFinite && y.isFinite && z.isFinite else { return .zero }
        return simd_float3(x - center.x, y - center.y, z - center.z)
    }

    private func safeQuaternion(from transform: simd_float4x4) -> simd_quatf {
        let col0 = simd_float3(transform.columns.0.x, transform.columns.0.y, transform.columns.0.z)
        let col1 = simd_float3(transform.columns.1.x, transform.columns.1.y, transform.columns.1.z)
        let col2 = simd_float3(transform.columns.2.x, transform.columns.2.y, transform.columns.2.z)

        guard col0.x.isFinite && col0.y.isFinite && col0.z.isFinite &&
              col1.x.isFinite && col1.y.isFinite && col1.z.isFinite &&
              col2.x.isFinite && col2.y.isFinite && col2.z.isFinite else {
            return simd_quatf(angle: 0, axis: simd_float3(0, 1, 0))
        }

        let rotationMatrix = simd_float3x3(col0, col1, col2)
        let det = simd_determinant(rotationMatrix)
        guard det.isFinite && abs(det) > 0.001 else {
            return simd_quatf(angle: 0, axis: simd_float3(0, 1, 0))
        }

        return simd_quatf(rotationMatrix)
    }
}

// MARK: - UIColor Hex Initializer

private extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
