import SwiftUI
import RoomPlan

struct ScanResultView: View {
    @ObservedObject var scanState: ScanState
    @Environment(\.dismiss) private var dismiss

    @State private var showQuantitySheet = false
    @State private var showMissingFixturesPrompt = false
    @State private var showAddFixtures = false
    @State private var measurements: RoomMeasurements?
    @State private var quantitySheet: QuantitySheet?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RemodlySpacing.lg) {
                    // 3D preview of scanned room
                    if let capturedRoom = scanState.capturedRoom, let measurements = measurements {
                        Room3DViewer(room: capturedRoom, measurements: measurements)
                            .frame(height: 300)
                            .cornerRadius(RemodlyRadius.large)
                    } else {
                        Rectangle()
                            .fill(Color.tungsten)
                            .frame(height: 300)
                            .cornerRadius(RemodlyRadius.large)
                            .overlay {
                                if scanState.capturedRoom != nil {
                                    VStack(spacing: RemodlySpacing.sm) {
                                        ProgressView()
                                            .tint(.copper)
                                        Text("Calculating measurements...")
                                            .font(.remodlySubhead)
                                            .foregroundColor(.bodyText)
                                    }
                                } else {
                                    Text("No scan data")
                                        .font(.remodlySubhead)
                                        .foregroundColor(.bodyText)
                                }
                            }
                    }

                    // Scan summary
                    RemodlyCard {
                        VStack(alignment: .leading, spacing: RemodlySpacing.sm) {
                            Text("Scan Summary")
                                .font(.remodlyHeadline)
                                .foregroundColor(.ivory)

                            HStack {
                                ScanSummaryItem(
                                    label: "Quality",
                                    value: "\(Int(scanState.qualityScore * 100))%",
                                    isHighlighted: scanState.qualityScore >= 0.7
                                )
                                ScanSummaryItem(label: "Walls", value: "\(scanState.wallCount)")
                                ScanSummaryItem(label: "Doors", value: "\(scanState.doorCount)")
                                ScanSummaryItem(label: "Windows", value: "\(scanState.windowCount)")
                            }
                        }
                    }

                    // Measurements overlay
                    if let measurements = measurements {
                        MeasurementOverlayView(measurements: measurements)
                    }

                    Spacer(minLength: RemodlySpacing.lg)

                    // Actions
                    VStack(spacing: RemodlySpacing.sm) {
                        RemodlyButton(
                            title: "Continue to Quantities",
                            icon: "arrow.right"
                        ) {
                            continueToQuantities()
                        }

                        RemodlyButton(
                            title: "Rescan",
                            style: .secondary,
                            icon: "arrow.counterclockwise"
                        ) {
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .background(Color.obsidian)
            .navigationTitle("Scan Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.obsidian, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.copper)
                }
            }
            .sheet(isPresented: $showQuantitySheet) {
                if let sheet = Binding($quantitySheet) {
                    QuantitySheetView(quantitySheet: sheet, roomType: scanState.roomType)
                }
            }
            .sheet(isPresented: $showAddFixtures, onDismiss: {
                // After adding fixtures, proceed to quantity sheet
                showMissingFixturesPrompt = false
                showQuantitySheet = true
            }) {
                if let sheet = Binding($quantitySheet) {
                    AddFixturesSheet(quantitySheet: sheet, roomType: scanState.roomType)
                }
            }
            .alert("Missing \(scanState.roomType.fixtureLabel)?", isPresented: $showMissingFixturesPrompt) {
                Button("Yes, Add \(scanState.roomType.fixtureLabel)") {
                    showAddFixtures = true
                }
                Button("No, Continue") {
                    showQuantitySheet = true
                }
            } message: {
                Text("Were there any \(scanState.roomType.fixtureLabel.lowercased()) that weren't detected during the scan?")
            }
            .onAppear {
                extractMeasurements()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func extractMeasurements() {
        guard let capturedRoom = scanState.capturedRoom else { return }
        measurements = MeasurementExtractor.extract(from: capturedRoom)
    }

    private func continueToQuantities() {
        guard let capturedRoom = scanState.capturedRoom,
              let measurements = measurements else { return }

        // Generate QuantitySheet from scan data
        let roomCaptureId = UUID().uuidString
        quantitySheet = QuantitySheetService.createFromScan(
            measurements: measurements,
            capturedRoom: capturedRoom,
            roomCaptureId: roomCaptureId,
            roomType: scanState.roomType
        )

        // Show missing fixtures prompt
        showMissingFixturesPrompt = true
    }
}

// MARK: - Supporting Views

struct ScanSummaryItem: View {
    let label: String
    let value: String
    var isHighlighted: Bool = false

    var body: some View {
        VStack(spacing: RemodlySpacing.xs) {
            Text(value)
                .font(.remodlyTitle3)
                .fontWeight(.bold)
                .foregroundColor(isHighlighted ? .signal : .ivory)

            Text(label)
                .font(.remodlyCaption)
                .foregroundColor(.bodyText)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScanResultView(scanState: ScanState())
}
