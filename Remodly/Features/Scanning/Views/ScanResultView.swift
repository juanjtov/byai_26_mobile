import SwiftUI
import RoomPlan

struct ScanResultView: View {
    @ObservedObject var scanState: ScanState
    @Environment(\.dismiss) private var dismiss
    @State private var showQuantitySheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 3D preview of scanned room
                if let capturedRoom = scanState.capturedRoom {
                    RoomPreviewView(room: capturedRoom)
                        .frame(height: 300)
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .cornerRadius(12)
                        .overlay {
                            Text("No scan data")
                                .foregroundColor(.secondary)
                        }
                }

                // Scan summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Scan Summary")
                        .font(.headline)

                    HStack {
                        ScanSummaryItem(label: "Quality", value: "\(Int(scanState.qualityScore * 100))%")
                        ScanSummaryItem(label: "Walls", value: "\(scanState.wallCount)")
                        ScanSummaryItem(label: "Doors", value: "\(scanState.doorCount)")
                        ScanSummaryItem(label: "Windows", value: "\(scanState.windowCount)")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                Spacer()

                // Actions
                VStack(spacing: 12) {
                    Button(action: { showQuantitySheet = true }) {
                        Text("Continue to Quantities")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Rescan") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("Scan Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showQuantitySheet) {
                QuantitySheetView()
            }
        }
    }
}

struct RoomPreviewView: View {
    let room: CapturedRoom

    var body: some View {
        // Placeholder for 3D room preview using SceneKit/RealityKit
        ZStack {
            Color.black.opacity(0.9)
            Image(systemName: "cube.transparent")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.5))
            Text("3D Preview")
                .foregroundColor(.white)
                .offset(y: 60)
        }
    }
}

struct ScanSummaryItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScanResultView(scanState: ScanState())
}
