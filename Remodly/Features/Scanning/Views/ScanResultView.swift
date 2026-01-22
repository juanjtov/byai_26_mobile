import SwiftUI
import RoomPlan

struct ScanResultView: View {
    @ObservedObject var scanState: ScanState
    @Environment(\.dismiss) private var dismiss
    @State private var showQuantitySheet = false
    @State private var measurements: RoomMeasurements?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 3D preview of scanned room
                    if let capturedRoom = scanState.capturedRoom, let measurements = measurements {
                        Room3DViewer(room: capturedRoom, measurements: measurements)
                            .frame(height: 300)
                            .cornerRadius(12)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .cornerRadius(12)
                            .overlay {
                                if scanState.capturedRoom != nil {
                                    ProgressView("Calculating measurements...")
                                } else {
                                    Text("No scan data")
                                        .foregroundColor(.secondary)
                                }
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

                    // Measurements overlay
                    if let measurements = measurements {
                        MeasurementOverlayView(measurements: measurements)
                    }

                    Spacer(minLength: 20)

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
            }
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
            .onAppear {
                extractMeasurements()
            }
        }
    }

    private func extractMeasurements() {
        guard let capturedRoom = scanState.capturedRoom else { return }
        measurements = MeasurementExtractor.extract(from: capturedRoom)
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
