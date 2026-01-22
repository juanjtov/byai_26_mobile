import SwiftUI

struct QuantitySheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var quantitySheet: QuantitySheet?
    @State private var isEditing = false
    @State private var showStyleSelection = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Area measurements
                    MeasurementSection(title: "Areas") {
                        MeasurementRow(
                            label: "Floor Area",
                            value: quantitySheet?.floorArea ?? 0,
                            unit: "sq ft",
                            isEditing: isEditing,
                            onUpdate: { newValue in
                                quantitySheet?.floorArea = newValue
                            }
                        )
                        MeasurementRow(
                            label: "Wall Area",
                            value: quantitySheet?.wallArea ?? 0,
                            unit: "sq ft",
                            isEditing: isEditing,
                            onUpdate: { newValue in
                                quantitySheet?.wallArea = newValue
                            }
                        )
                        MeasurementRow(
                            label: "Perimeter",
                            value: quantitySheet?.perimeterLength ?? 0,
                            unit: "lin ft",
                            isEditing: isEditing,
                            onUpdate: { newValue in
                                quantitySheet?.perimeterLength = newValue
                            }
                        )
                        MeasurementRow(
                            label: "Ceiling Height",
                            value: quantitySheet?.ceilingHeight ?? 0,
                            unit: "ft",
                            isEditing: isEditing,
                            onUpdate: { newValue in
                                quantitySheet?.ceilingHeight = newValue
                            }
                        )
                    }

                    // Openings
                    MeasurementSection(title: "Openings") {
                        CountRow(
                            label: "Doors",
                            count: quantitySheet?.doorCount ?? 0,
                            isEditing: isEditing,
                            onUpdate: { newCount in
                                quantitySheet?.doorCount = newCount
                            }
                        )
                        CountRow(
                            label: "Windows",
                            count: quantitySheet?.windowCount ?? 0,
                            isEditing: isEditing,
                            onUpdate: { newCount in
                                quantitySheet?.windowCount = newCount
                            }
                        )
                    }

                    // Fixtures
                    MeasurementSection(title: "Fixtures") {
                        if let fixtures = quantitySheet?.fixtures {
                            ForEach(fixtures) { fixture in
                                CountRow(
                                    label: fixture.type.displayName,
                                    count: fixture.count,
                                    isEditing: isEditing,
                                    onUpdate: { _ in }
                                )
                            }
                        } else {
                            Text("No fixtures detected")
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer(minLength: 20)

                    // Continue button
                    Button(action: { showStyleSelection = true }) {
                        Text("Continue to Style Selection")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Quantity Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
            }
            .sheet(isPresented: $showStyleSelection) {
                StyleSelectionView()
            }
            .onAppear {
                loadSampleQuantities()
            }
        }
    }

    private func loadSampleQuantities() {
        // Sample data - in reality this comes from RoomPlan extraction
        quantitySheet = QuantitySheet(
            id: UUID().uuidString,
            roomCaptureId: "capture_1",
            version: 1,
            floorArea: 48.5,
            wallArea: 186.2,
            perimeterLength: 27.8,
            ceilingHeight: 9.0,
            doorCount: 1,
            doorSizes: [QuantitySheet.DoorSize(width: 32, height: 80)],
            windowCount: 1,
            windowSizes: [QuantitySheet.WindowSize(width: 36, height: 48)],
            fixtures: [
                QuantitySheet.Fixture(id: "1", type: .toilet, count: 1),
                QuantitySheet.Fixture(id: "2", type: .vanity, count: 1),
                QuantitySheet.Fixture(id: "3", type: .shower, count: 1)
            ],
            isLocked: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

struct MeasurementSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            VStack(spacing: 8) {
                content
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct MeasurementRow: View {
    let label: String
    let value: Double
    let unit: String
    let isEditing: Bool
    let onUpdate: (Double) -> Void

    @State private var editValue: String = ""

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            if isEditing {
                TextField("", text: $editValue)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
                    .onAppear { editValue = String(format: "%.1f", value) }
                    .onChange(of: editValue) { _, newValue in
                        if let doubleValue = Double(newValue) {
                            onUpdate(doubleValue)
                        }
                    }
            } else {
                Text(String(format: "%.1f", value))
                    .fontWeight(.medium)
            }
            Text(unit)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
        }
    }
}

struct CountRow: View {
    let label: String
    let count: Int
    let isEditing: Bool
    let onUpdate: (Int) -> Void

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            if isEditing {
                Stepper("\(count)", value: .constant(count), in: 0...20)
                    .labelsHidden()
            } else {
                Text("\(count)")
                    .fontWeight(.medium)
            }
        }
    }
}

#Preview {
    QuantitySheetView()
}
