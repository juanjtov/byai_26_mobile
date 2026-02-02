import SwiftUI

/// Sheet for adding missing fixtures that weren't detected by RoomPlan
struct AddFixturesSheet: View {
    @Binding var quantitySheet: QuantitySheet
    let roomType: RoomCapture.RoomType
    @Environment(\.dismiss) private var dismiss

    @State private var customFixtureName = ""
    @State private var showCustomInput = false

    /// Available preset fixture types based on room type
    private var presetFixtures: [QuantitySheet.Fixture.FixtureType] {
        FixtureDetector.presetsForRoomType(roomType)
    }

    /// Suggested missing fixtures
    private var suggestedFixtures: [QuantitySheet.Fixture.FixtureType] {
        FixtureDetector.suggestMissingFixtures(detected: quantitySheet.fixtures, roomType: roomType)
    }

    /// Label for this room type
    private var itemLabel: String {
        roomType.fixtureLabel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RemodlySpacing.lg) {
                    // Header with room type context
                    VStack(alignment: .leading, spacing: RemodlySpacing.sm) {
                        HStack {
                            Image(systemName: roomType.icon)
                                .foregroundColor(.copper)
                            Text(roomType.displayName)
                                .font(.remodlySubhead)
                                .foregroundColor(.bodyText)
                        }

                        Text("Add Missing \(itemLabel)")
                            .font(.remodlyTitle2)
                            .foregroundColor(.ivory)

                        Text("Select any \(itemLabel.lowercased()) that weren't detected during the scan.")
                            .font(.remodlyBody)
                            .foregroundColor(.bodyText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // Suggested missing fixtures (highlighted)
                    if !suggestedFixtures.isEmpty {
                        VStack(alignment: .leading, spacing: RemodlySpacing.sm) {
                            Text("Commonly Missing")
                                .font(.remodlyHeadline)
                                .foregroundColor(.gold)
                                .padding(.horizontal)

                            ForEach(suggestedFixtures, id: \.self) { fixtureType in
                                PresetFixtureRow(
                                    fixtureType: fixtureType,
                                    isAdded: isFixtureAdded(fixtureType),
                                    isHighlighted: true
                                ) {
                                    addFixture(fixtureType)
                                }
                            }
                        }
                    }

                    // Current fixtures
                    if !quantitySheet.fixtures.isEmpty {
                        VStack(alignment: .leading, spacing: RemodlySpacing.sm) {
                            Text("Detected \(itemLabel)")
                                .font(.remodlyHeadline)
                                .foregroundColor(.ivory)
                                .padding(.horizontal)

                            ForEach(quantitySheet.fixtures) { fixture in
                                DetectedFixtureRow(fixture: fixture) {
                                    removeFixture(fixture)
                                }
                            }
                        }
                    }

                    // All available fixtures for room type
                    VStack(alignment: .leading, spacing: RemodlySpacing.sm) {
                        Text("All \(itemLabel)")
                            .font(.remodlyHeadline)
                            .foregroundColor(.ivory)
                            .padding(.horizontal)

                        ForEach(presetFixtures, id: \.self) { fixtureType in
                            PresetFixtureRow(
                                fixtureType: fixtureType,
                                isAdded: isFixtureAdded(fixtureType),
                                isHighlighted: false
                            ) {
                                addFixture(fixtureType)
                            }
                        }

                        // Custom fixture button
                        Button(action: { showCustomInput = true }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.copper)
                                Text("Add Custom \(roomType == .bathroom ? "Fixture" : "Appliance")")
                                    .foregroundColor(.copper)
                                Spacer()
                            }
                            .font(.remodlyBody)
                            .padding()
                            .background(Color.copperSubtle)
                            .cornerRadius(RemodlyRadius.medium)
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: RemodlySpacing.xl)

                    // Done button
                    RemodlyButton(title: "Done") {
                        dismiss()
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.obsidian)
            .navigationTitle(itemLabel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.copper)
                }
            }
            .alert("Add Custom \(roomType == .bathroom ? "Fixture" : "Appliance")", isPresented: $showCustomInput) {
                TextField("Name", text: $customFixtureName)
                Button("Cancel", role: .cancel) {
                    customFixtureName = ""
                }
                Button("Add") {
                    // For custom fixtures, we'd need to extend the model
                    // For now, this is a placeholder
                    customFixtureName = ""
                }
            } message: {
                Text("Enter a name for the custom \(roomType == .bathroom ? "fixture" : "appliance")")
            }
        }
    }

    private func isFixtureAdded(_ type: QuantitySheet.Fixture.FixtureType) -> Bool {
        quantitySheet.fixtures.contains { $0.type == type }
    }

    private func addFixture(_ type: QuantitySheet.Fixture.FixtureType) {
        guard !isFixtureAdded(type) else { return }
        quantitySheet = QuantitySheetService.addFixture(to: quantitySheet, type: type)
    }

    private func removeFixture(_ fixture: QuantitySheet.Fixture) {
        quantitySheet = QuantitySheetService.removeFixture(from: quantitySheet, fixtureId: fixture.id)
    }
}

/// Row showing a detected fixture with remove option
struct DetectedFixtureRow: View {
    let fixture: QuantitySheet.Fixture
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Image(systemName: fixture.type.icon)
                .foregroundColor(.signal)
                .frame(width: 32)

            Text(fixture.type.displayName)
                .font(.remodlyBody)
                .foregroundColor(.ivory)

            Spacer()

            Text("x\(fixture.count)")
                .font(.remodlySubhead)
                .foregroundColor(.bodyText)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.bodyText)
            }
        }
        .padding()
        .background(Color.tungsten)
        .cornerRadius(RemodlyRadius.medium)
        .padding(.horizontal)
    }
}

/// Row for adding a preset fixture type
struct PresetFixtureRow: View {
    let fixtureType: QuantitySheet.Fixture.FixtureType
    let isAdded: Bool
    var isHighlighted: Bool = false
    let onAdd: () -> Void

    var body: some View {
        Button(action: {
            if !isAdded {
                onAdd()
            }
        }) {
            HStack {
                Image(systemName: fixtureType.icon)
                    .foregroundColor(isAdded ? .signal : (isHighlighted ? .gold : .bodyText))
                    .frame(width: 32)

                Text(fixtureType.displayName)
                    .font(.remodlyBody)
                    .foregroundColor(isAdded ? .ivory : (isHighlighted ? .ivory : .bodyText))

                Spacer()

                if isAdded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.signal)
                } else {
                    Image(systemName: "plus.circle")
                        .foregroundColor(isHighlighted ? .gold : .copper)
                }
            }
            .padding()
            .background(isAdded ? Color.tungsten : (isHighlighted ? Color.gold.opacity(0.1) : Color.ivorySubtle))
            .cornerRadius(RemodlyRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: RemodlyRadius.medium)
                    .stroke(isHighlighted && !isAdded ? Color.gold.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .disabled(isAdded)
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview("Bathroom") {
    AddFixturesSheet(
        quantitySheet: .constant(
            QuantitySheet(
                id: "preview",
                roomCaptureId: "capture_1",
                version: 1,
                floorArea: 48.5,
                wallArea: 186.2,
                perimeterLength: 27.8,
                ceilingHeight: 9.0,
                doorCount: 1,
                doorSizes: [],
                windowCount: 1,
                windowSizes: [],
                fixtures: [
                    QuantitySheet.Fixture(id: "1", type: .toilet, count: 1)
                ],
                isLocked: false,
                createdAt: Date(),
                updatedAt: Date()
            )
        ),
        roomType: .bathroom
    )
}

#Preview("Kitchen") {
    AddFixturesSheet(
        quantitySheet: .constant(
            QuantitySheet(
                id: "preview",
                roomCaptureId: "capture_1",
                version: 1,
                floorArea: 120.0,
                wallArea: 280.0,
                perimeterLength: 42.0,
                ceilingHeight: 9.0,
                doorCount: 1,
                doorSizes: [],
                windowCount: 2,
                windowSizes: [],
                fixtures: [
                    QuantitySheet.Fixture(id: "1", type: .refrigerator, count: 1),
                    QuantitySheet.Fixture(id: "2", type: .sink, count: 1)
                ],
                isLocked: false,
                createdAt: Date(),
                updatedAt: Date()
            )
        ),
        roomType: .kitchen
    )
}
