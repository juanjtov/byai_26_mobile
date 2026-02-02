import SwiftUI
import RealityKit
import RoomPlan
import simd

/// 3D visualization of a scanned room using RealityKit
struct Room3DViewer: View {
    let room: CapturedRoom
    let measurements: RoomMeasurements
    @State private var zoomLevel: Float = 1.0

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Room3DViewContainer(room: room, measurements: measurements, zoomLevel: $zoomLevel)
                .background(Color.black.opacity(0.9))

            // Zoom indicator
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                Text(String(format: "%.1fx", zoomLevel))
                    .font(.caption.monospacedDigit())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .padding()
        }
    }
}

/// UIViewRepresentable wrapper for ARView showing room geometry
struct Room3DViewContainer: UIViewRepresentable {
    let room: CapturedRoom
    let measurements: RoomMeasurements
    @Binding var zoomLevel: Float

    func makeCoordinator() -> Room3DCoordinator {
        Room3DCoordinator(zoomLevel: $zoomLevel)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Disable AR session - we're doing non-AR visualization
        arView.cameraMode = .nonAR
        arView.environment.background = .color(.black.withAlphaComponent(0.9))

        // Create and add the room anchor
        let roomAnchor = createRoomAnchor(coordinator: context.coordinator)
        arView.scene.addAnchor(roomAnchor)
        context.coordinator.roomAnchor = roomAnchor

        // Setup camera position with coordinator
        setupCamera(arView: arView, coordinator: context.coordinator)

        // Add ambient lighting
        setupLighting(arView: arView)

        // Add gesture recognizers
        let pinchGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Room3DCoordinator.handlePinch(_:))
        )
        arView.addGestureRecognizer(pinchGesture)

        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Room3DCoordinator.handlePan(_:))
        )
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        arView.addGestureRecognizer(panGesture)

        context.coordinator.arView = arView

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Update label orientations to face camera (billboard effect)
        context.coordinator.updateLabelOrientations()
    }

    private func createRoomAnchor(coordinator: Room3DCoordinator) -> AnchorEntity {
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
                if let labelContainer = createMeasurementLabel(
                    text: String(format: "%.1f' x %.1f'", dims.width, dims.height),
                    surface: wall,
                    roomCenter: center,
                    color: .white,
                    backgroundColor: UIColor.black.withAlphaComponent(0.75)
                ) {
                    anchor.addChild(labelContainer)
                    coordinator.measurementLabels.append(labelContainer)
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
                if let labelContainer = createMeasurementLabel(
                    text: String(format: "D: %.1f' x %.1f'", dims.width, dims.height),
                    surface: door,
                    roomCenter: center,
                    color: .orange,
                    backgroundColor: UIColor.black.withAlphaComponent(0.75)
                ) {
                    anchor.addChild(labelContainer)
                    coordinator.measurementLabels.append(labelContainer)
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
                if let labelContainer = createMeasurementLabel(
                    text: String(format: "W: %.1f' x %.1f'", dims.width, dims.height),
                    surface: window,
                    roomCenter: center,
                    color: .cyan,
                    backgroundColor: UIColor.black.withAlphaComponent(0.75)
                ) {
                    anchor.addChild(labelContainer)
                    coordinator.measurementLabels.append(labelContainer)
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

    private func createMeasurementLabel(
        text: String,
        surface: CapturedRoom.Surface,
        roomCenter: simd_float3,
        color: UIColor,
        backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.7)
    ) -> Entity? {
        // Validate surface has usable data
        guard isValidSurface(surface) else {
            return nil
        }

        // Create container entity for billboard behavior
        let container = Entity()

        // Larger font for better readability when zoomed
        let fontSize: CGFloat = 0.12

        // Use a proper container frame to avoid crash with .zero
        let containerFrame = CGRect(x: 0, y: 0, width: 2.0, height: 0.5)

        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.002,
            font: .systemFont(ofSize: fontSize, weight: .bold),
            containerFrame: containerFrame,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )

        var textMaterial = SimpleMaterial()
        textMaterial.color = .init(tint: color)

        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.position = simd_float3(0, 0, 0.01) // Slightly in front of background

        // Create background plane for contrast
        let textWidth: Float = Float(text.count) * Float(fontSize) * 0.6
        let bgWidth = max(textWidth + 0.1, 0.5)
        let bgHeight: Float = Float(fontSize) * 1.8

        let bgMesh = MeshResource.generatePlane(width: bgWidth, height: bgHeight, cornerRadius: 0.02)
        var bgMaterial = SimpleMaterial()
        bgMaterial.color = .init(tint: backgroundColor)

        let bgEntity = ModelEntity(mesh: bgMesh, materials: [bgMaterial])
        bgEntity.position = simd_float3(bgWidth / 2 - 0.05, Float(fontSize) * 0.5, 0) // Center behind text

        container.addChild(bgEntity)
        container.addChild(textEntity)

        // Position label at wall midpoint, slightly in front
        var position = safePosition(from: surface.transform, relativeTo: roomCenter)
        position.y += surface.dimensions.y / 2 + 0.15

        // Move label outward from room center for visibility
        let directionFromCenter = normalize(simd_float3(position.x, 0, position.z))
        position.x += directionFromCenter.x * 0.2
        position.z += directionFromCenter.z * 0.2

        container.position = position

        return container
    }

    private func setupCamera(arView: ARView, coordinator: Room3DCoordinator) {
        // Position camera for isometric-like view
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 60

        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)
        arView.scene.addAnchor(cameraAnchor)

        // Store references in coordinator for gesture handling
        coordinator.cameraEntity = cameraEntity
        coordinator.cameraAnchor = cameraAnchor

        // Initialize camera position using spherical coordinates
        coordinator.updateCameraPosition()
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

// MARK: - Coordinator for Gesture Handling

class Room3DCoordinator: NSObject {
    // Camera state (spherical coordinates)
    var cameraDistance: Float = 8.0
    var cameraYaw: Float = 0.785  // ~45 degrees
    var cameraPitch: Float = 0.5  // ~30 degrees up

    // Distance limits
    private let minDistance: Float = 3.0
    private let maxDistance: Float = 15.0

    // Pitch limits (avoid gimbal lock)
    private let minPitch: Float = 0.1
    private let maxPitch: Float = 1.4  // ~80 degrees

    // References
    weak var arView: ARView?
    var cameraEntity: PerspectiveCamera?
    var cameraAnchor: AnchorEntity?
    var roomAnchor: AnchorEntity?
    var measurementLabels: [Entity] = []

    // Gesture state
    private var lastPinchScale: CGFloat = 1.0
    private var lastPanLocation: CGPoint = .zero

    // Binding for zoom level display
    @Binding var zoomLevel: Float

    init(zoomLevel: Binding<Float>) {
        self._zoomLevel = zoomLevel
        super.init()
    }

    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            lastPinchScale = gesture.scale

        case .changed:
            let scaleDelta = Float(gesture.scale / lastPinchScale)
            lastPinchScale = gesture.scale

            // Invert: pinch out = zoom in (smaller distance)
            cameraDistance /= scaleDelta
            cameraDistance = min(max(cameraDistance, minDistance), maxDistance)

            // Update zoom level for UI display
            DispatchQueue.main.async {
                self.zoomLevel = self.maxDistance / self.cameraDistance
            }

            updateCameraPosition()
            updateLabelOrientations()

        case .ended, .cancelled:
            lastPinchScale = 1.0

        default:
            break
        }
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }

        switch gesture.state {
        case .began:
            lastPanLocation = gesture.location(in: view)

        case .changed:
            let currentLocation = gesture.location(in: view)
            let deltaX = Float(currentLocation.x - lastPanLocation.x)
            let deltaY = Float(currentLocation.y - lastPanLocation.y)
            lastPanLocation = currentLocation

            // Sensitivity for rotation
            let sensitivity: Float = 0.01

            // Horizontal drag: rotate around Y-axis (yaw)
            cameraYaw -= deltaX * sensitivity

            // Vertical drag: tilt up/down (pitch)
            cameraPitch += deltaY * sensitivity
            cameraPitch = min(max(cameraPitch, minPitch), maxPitch)

            updateCameraPosition()
            updateLabelOrientations()

        case .ended, .cancelled:
            lastPanLocation = .zero

        default:
            break
        }
    }

    func updateCameraPosition() {
        guard let camera = cameraEntity else { return }

        // Convert spherical coordinates to Cartesian
        // x = r * cos(pitch) * sin(yaw)
        // y = r * sin(pitch) + offset
        // z = r * cos(pitch) * cos(yaw)
        let x = cameraDistance * cos(cameraPitch) * sin(cameraYaw)
        let y = cameraDistance * sin(cameraPitch) + 2.0  // Offset above floor
        let z = cameraDistance * cos(cameraPitch) * cos(cameraYaw)

        camera.position = simd_float3(x, y, z)
        camera.look(at: simd_float3(0, 1, 0), from: camera.position, relativeTo: nil)
    }

    func updateLabelOrientations() {
        guard let camera = cameraEntity else { return }

        let cameraPos = camera.position

        for label in measurementLabels {
            // Billboard effect: make label face the camera
            let labelPos = label.position
            let direction = cameraPos - labelPos

            // Only rotate around Y-axis to keep labels upright
            let yawToCamera = atan2(direction.x, direction.z)
            label.orientation = simd_quatf(angle: yawToCamera, axis: simd_float3(0, 1, 0))
        }
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
