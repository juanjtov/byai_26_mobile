import SwiftUI
import RealityKit
import RoomPlan
import simd

/// 3D visualization of a scanned room using RealityKit
struct Room3DViewer: View {
    let room: CapturedRoom
    let measurements: RoomMeasurements

    var body: some View {
        Room3DViewContainer(room: room, measurements: measurements)
            .background(Color.black.opacity(0.9))
    }
}

/// UIViewRepresentable wrapper for ARView showing room geometry
struct Room3DViewContainer: UIViewRepresentable {
    let room: CapturedRoom
    let measurements: RoomMeasurements

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Disable AR session - we're doing non-AR visualization
        arView.cameraMode = .nonAR
        arView.environment.background = .color(.black.withAlphaComponent(0.9))

        // Create and add the room anchor
        let roomAnchor = createRoomAnchor()
        arView.scene.addAnchor(roomAnchor)

        // Setup camera position
        setupCamera(arView: arView)

        // Add ambient lighting
        setupLighting(arView: arView)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Updates not needed for static visualization
    }

    private func createRoomAnchor() -> AnchorEntity {
        let anchor = AnchorEntity(world: .zero)

        // Calculate room center for proper positioning
        let center = calculateRoomCenter()

        // Add walls (skip any with invalid data)
        for (index, wall) in room.walls.enumerated() {
            if let wallEntity = createWallEntity(surface: wall, index: index, roomCenter: center) {
                anchor.addChild(wallEntity)
            }

            // Add measurement label for this wall
            if index < measurements.wallDimensions.count {
                let dims = measurements.wallDimensions[index]
                if let labelEntity = createMeasurementLabel(
                    text: String(format: "%.1f' x %.1f'", dims.width, dims.height),
                    surface: wall,
                    roomCenter: center,
                    color: .white
                ) {
                    anchor.addChild(labelEntity)
                }
            }
        }

        // Add doors (skip any with invalid data)
        for (index, door) in room.doors.enumerated() {
            if let doorEntity = createDoorEntity(surface: door, roomCenter: center) {
                anchor.addChild(doorEntity)
            }

            // Add door measurement label
            if index < measurements.doorDimensions.count {
                let dims = measurements.doorDimensions[index]
                if let labelEntity = createMeasurementLabel(
                    text: String(format: "D: %.1f' x %.1f'", dims.width, dims.height),
                    surface: door,
                    roomCenter: center,
                    color: .orange
                ) {
                    anchor.addChild(labelEntity)
                }
            }
        }

        // Add windows (skip any with invalid data)
        for (index, window) in room.windows.enumerated() {
            if let windowEntity = createWindowEntity(surface: window, roomCenter: center) {
                anchor.addChild(windowEntity)
            }

            // Add window measurement label
            if index < measurements.windowDimensions.count {
                let dims = measurements.windowDimensions[index]
                if let labelEntity = createMeasurementLabel(
                    text: String(format: "W: %.1f' x %.1f'", dims.width, dims.height),
                    surface: window,
                    roomCenter: center,
                    color: .cyan
                ) {
                    anchor.addChild(labelEntity)
                }
            }
        }

        // Add floor indicator
        let floorEntity = createFloorEntity(roomCenter: center)
        anchor.addChild(floorEntity)

        return anchor
    }

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

    // MARK: - Validation Helpers

    /// Safely extracts a quaternion from a transform matrix, returning identity if invalid
    private func safeQuaternion(from transform: simd_float4x4) -> simd_quatf {
        // Extract rotation matrix (upper 3x3)
        let col0 = simd_float3(transform.columns.0.x, transform.columns.0.y, transform.columns.0.z)
        let col1 = simd_float3(transform.columns.1.x, transform.columns.1.y, transform.columns.1.z)
        let col2 = simd_float3(transform.columns.2.x, transform.columns.2.y, transform.columns.2.z)

        // Check for NaN or infinity in rotation columns
        guard col0.x.isFinite && col0.y.isFinite && col0.z.isFinite &&
              col1.x.isFinite && col1.y.isFinite && col1.z.isFinite &&
              col2.x.isFinite && col2.y.isFinite && col2.z.isFinite else {
            return simd_quatf(angle: 0, axis: simd_float3(0, 1, 0))
        }

        // Check for valid rotation matrix (determinant should be ~1 for orthonormal)
        let rotationMatrix = simd_float3x3(col0, col1, col2)
        let det = simd_determinant(rotationMatrix)
        guard det.isFinite && abs(det) > 0.001 else {
            return simd_quatf(angle: 0, axis: simd_float3(0, 1, 0))
        }

        return simd_quatf(rotationMatrix)
    }

    /// Validates that a dimension value is positive and finite
    private func isValidDimension(_ value: Float) -> Bool {
        value.isFinite && value > 0.001
    }

    /// Validates that a surface has usable dimensions for mesh generation
    private func isValidSurface(_ surface: CapturedRoom.Surface) -> Bool {
        isValidDimension(surface.dimensions.x) && isValidDimension(surface.dimensions.y)
    }

    /// Extracts position from transform, returning zero if invalid
    private func safePosition(from transform: simd_float4x4, relativeTo center: simd_float3) -> simd_float3 {
        let x = transform.columns.3.x
        let y = transform.columns.3.y
        let z = transform.columns.3.z

        guard x.isFinite && y.isFinite && z.isFinite else {
            return .zero
        }

        return simd_float3(x - center.x, y - center.y, z - center.z)
    }

    // MARK: - Entity Creation

    private func createWallEntity(surface: CapturedRoom.Surface, index: Int, roomCenter: simd_float3) -> ModelEntity? {
        // Validate dimensions before mesh generation
        guard isValidSurface(surface) else {
            return nil
        }

        let width = surface.dimensions.x
        let height = surface.dimensions.y
        let depth: Float = 0.05 // Thin wall representation

        let mesh = MeshResource.generateBox(width: width, height: height, depth: depth, cornerRadius: 0)
        var material = SimpleMaterial()
        material.color = .init(tint: .systemBlue.withAlphaComponent(0.6))
        material.metallic = .float(0.1)
        material.roughness = .float(0.8)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position relative to room center (with validation)
        entity.position = safePosition(from: surface.transform, relativeTo: roomCenter)

        // Extract rotation from transform safely
        entity.orientation = safeQuaternion(from: surface.transform)

        return entity
    }

    private func createDoorEntity(surface: CapturedRoom.Surface, roomCenter: simd_float3) -> ModelEntity? {
        // Validate dimensions before mesh generation
        guard isValidSurface(surface) else {
            return nil
        }

        let width = surface.dimensions.x
        let height = surface.dimensions.y
        let depth: Float = 0.08

        let mesh = MeshResource.generateBox(width: width, height: height, depth: depth, cornerRadius: 0)
        var material = SimpleMaterial()
        material.color = .init(tint: .orange.withAlphaComponent(0.7))
        material.metallic = .float(0.2)
        material.roughness = .float(0.6)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position relative to room center (with validation)
        entity.position = safePosition(from: surface.transform, relativeTo: roomCenter)

        // Extract rotation from transform safely
        entity.orientation = safeQuaternion(from: surface.transform)

        return entity
    }

    private func createWindowEntity(surface: CapturedRoom.Surface, roomCenter: simd_float3) -> ModelEntity? {
        // Validate dimensions before mesh generation
        guard isValidSurface(surface) else {
            return nil
        }

        let width = surface.dimensions.x
        let height = surface.dimensions.y
        let depth: Float = 0.06

        let mesh = MeshResource.generateBox(width: width, height: height, depth: depth, cornerRadius: 0)
        var material = SimpleMaterial()
        material.color = .init(tint: .cyan.withAlphaComponent(0.5))
        material.metallic = .float(0.4)
        material.roughness = .float(0.3)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position relative to room center (with validation)
        entity.position = safePosition(from: surface.transform, relativeTo: roomCenter)

        // Extract rotation from transform safely
        entity.orientation = safeQuaternion(from: surface.transform)

        return entity
    }

    private func createFloorEntity(roomCenter: simd_float3) -> ModelEntity {
        // Create a floor plane based on room bounds
        let floorSize: Float = 5.0 // Default floor size
        let mesh = MeshResource.generatePlane(width: floorSize, depth: floorSize)

        var material = SimpleMaterial()
        material.color = .init(tint: .gray.withAlphaComponent(0.3))
        material.metallic = .float(0.0)
        material.roughness = .float(1.0)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position floor at bottom of room
        let lowestWallY = room.walls.map { $0.transform.columns.3.y - $0.dimensions.y / 2 }.min() ?? 0
        entity.position = simd_float3(0, lowestWallY - roomCenter.y - 0.01, 0)

        return entity
    }

    private func createMeasurementLabel(text: String, surface: CapturedRoom.Surface, roomCenter: simd_float3, color: UIColor) -> ModelEntity? {
        // Validate surface has usable data
        guard isValidSurface(surface) else {
            return nil
        }

        // Use a proper container frame to avoid crash with .zero
        let containerFrame = CGRect(x: 0, y: 0, width: 2.0, height: 0.5)

        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.08, weight: .medium),
            containerFrame: containerFrame,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )

        var material = SimpleMaterial()
        material.color = .init(tint: color)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position label slightly in front of and above the surface center (with validation)
        var position = safePosition(from: surface.transform, relativeTo: roomCenter)
        position.y += surface.dimensions.y / 2 + 0.1
        position.z += 0.15
        entity.position = position

        // Scale for visibility
        entity.scale = simd_float3(repeating: 1.0)

        return entity
    }

    private func setupCamera(arView: ARView) {
        // Position camera for isometric-like view
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 60

        // Position camera at an isometric angle
        let cameraDistance: Float = 6.0
        let cameraHeight: Float = 4.0
        cameraEntity.position = simd_float3(cameraDistance, cameraHeight, cameraDistance)

        // Look at center
        cameraEntity.look(at: .zero, from: cameraEntity.position, relativeTo: nil)

        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)
        arView.scene.addAnchor(cameraAnchor)
    }

    private func setupLighting(arView: ARView) {
        // Add directional light
        let lightAnchor = AnchorEntity(world: .zero)

        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 1000
        directionalLight.light.color = .white
        directionalLight.position = simd_float3(2, 5, 2)
        directionalLight.look(at: .zero, from: directionalLight.position, relativeTo: nil)

        lightAnchor.addChild(directionalLight)
        arView.scene.addAnchor(lightAnchor)
    }
}

#Preview {
    // Preview requires actual CapturedRoom data
    Rectangle()
        .fill(Color.black.opacity(0.9))
        .overlay {
            Text("Room3DViewer Preview\n(requires CapturedRoom)")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(height: 300)
}
