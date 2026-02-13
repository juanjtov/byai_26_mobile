import SwiftUI
import RoomPlan

struct QuantitySheetView: View {
    @Binding var quantitySheet: QuantitySheet
    var roomType: RoomCapture.RoomType = .bathroom
    let capturedRoom: CapturedRoom
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var showStyleSelection = false
    @State private var showAddFixtures = false
    @State private var showLockConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RemodlySpacing.lg) {
                    // Lock status banner
                    if quantitySheet.isLocked {
                        LockedBanner()
                    }

                    // Area measurements
                    RemodlyCard {
                        VStack(alignment: .leading, spacing: RemodlySpacing.sm) {
                            RemodlySectionHeader(title: "Areas", icon: "square.grid.2x2")

                            VStack(spacing: RemodlySpacing.sm) {
                                MeasurementRow(
                                    label: "Floor Area",
                                    value: $quantitySheet.floorArea,
                                    unit: "sq ft",
                                    isEditing: isEditing && !quantitySheet.isLocked
                                )
                                MeasurementRow(
                                    label: "Wall Area",
                                    value: $quantitySheet.wallArea,
                                    unit: "sq ft",
                                    isEditing: isEditing && !quantitySheet.isLocked
                                )
                                MeasurementRow(
                                    label: "Perimeter",
                                    value: $quantitySheet.perimeterLength,
                                    unit: "lin ft",
                                    isEditing: isEditing && !quantitySheet.isLocked
                                )
                                MeasurementRow(
                                    label: "Ceiling Height",
                                    value: $quantitySheet.ceilingHeight,
                                    unit: "ft",
                                    isEditing: isEditing && !quantitySheet.isLocked
                                )
                            }
                        }
                    }

                    // Openings
                    RemodlyCard {
                        VStack(alignment: .leading, spacing: RemodlySpacing.sm) {
                            RemodlySectionHeader(title: "Openings", icon: "door.left.hand.open")

                            VStack(spacing: RemodlySpacing.sm) {
                                CountRow(
                                    label: "Doors",
                                    count: $quantitySheet.doorCount,
                                    isEditing: isEditing && !quantitySheet.isLocked
                                )
                                CountRow(
                                    label: "Windows",
                                    count: $quantitySheet.windowCount,
                                    isEditing: isEditing && !quantitySheet.isLocked
                                )
                            }
                        }
                    }

                    // Fixtures / Appliances
                    RemodlyCard {
                        VStack(alignment: .leading, spacing: RemodlySpacing.sm) {
                            HStack {
                                RemodlySectionHeader(title: roomType.fixtureLabel, icon: fixturesSectionIcon)

                                Spacer()

                                if !quantitySheet.isLocked {
                                    Button(action: { showAddFixtures = true }) {
                                        HStack(spacing: RemodlySpacing.xs) {
                                            Image(systemName: "plus")
                                            Text("Add")
                                        }
                                        .font(.remodlySubhead)
                                        .foregroundColor(.copper)
                                    }
                                }
                            }

                            if quantitySheet.fixtures.isEmpty {
                                Text("No fixtures added")
                                    .font(.remodlyBody)
                                    .foregroundColor(.bodyText)
                                    .padding(.vertical, RemodlySpacing.sm)
                            } else {
                                VStack(spacing: RemodlySpacing.sm) {
                                    ForEach(quantitySheet.fixtures) { fixture in
                                        FixtureRow(fixture: fixture)
                                    }
                                }
                            }
                        }
                    }

                    // Version info
                    HStack {
                        Text("Version \(quantitySheet.version)")
                            .font(.remodlyCaption)
                            .foregroundColor(.bodyText)

                        Spacer()

                        Text("Updated \(quantitySheet.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.remodlyCaption)
                            .foregroundColor(.bodyText)
                    }
                    .padding(.horizontal, RemodlySpacing.xs)

                    Spacer(minLength: RemodlySpacing.lg)

                    // Actions
                    VStack(spacing: RemodlySpacing.sm) {
                        if quantitySheet.isLocked {
                            RemodlyButton(
                                title: "Continue to Style Selection",
                                icon: "paintbrush"
                            ) {
                                showStyleSelection = true
                            }
                        } else {
                            RemodlyButton(
                                title: "Lock for Pricing",
                                icon: "lock"
                            ) {
                                showLockConfirmation = true
                            }
                            .signalGlow(intensity: 0.3)
                        }
                    }
                }
                .padding()
            }
            .background(Color.obsidian)
            .navigationTitle("Quantity Sheet")
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

                if !quantitySheet.isLocked {
                    ToolbarItem(placement: .primaryAction) {
                        Button(isEditing ? "Done" : "Edit") {
                            isEditing.toggle()
                        }
                        .foregroundColor(.copper)
                    }
                }
            }
            .sheet(isPresented: $showStyleSelection) {
                StyleSelectionView(capturedRoom: capturedRoom)
            }
            .sheet(isPresented: $showAddFixtures) {
                AddFixturesSheet(quantitySheet: $quantitySheet, roomType: roomType)
            }
            .alert("Lock for Pricing?", isPresented: $showLockConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Lock") {
                    lockQuantitySheet()
                }
            } message: {
                Text("Once locked, measurements cannot be edited. This version will be used for estimate generation.")
            }
        }
        .preferredColorScheme(.dark)
    }

    private func lockQuantitySheet() {
        quantitySheet = QuantitySheetService.lockForPricing(quantitySheet)
        showStyleSelection = true
    }

    private var fixturesSectionIcon: String {
        switch roomType {
        case .bathroom: return "toilet"
        case .kitchen: return "refrigerator"
        case .utility: return "washer"
        default: return "cube"
        }
    }
}

// MARK: - Supporting Views

struct LockedBanner: View {
    var body: some View {
        HStack(spacing: RemodlySpacing.sm) {
            Image(systemName: "lock.fill")
                .foregroundColor(.signal)

            Text("Locked for Pricing")
                .font(.remodlySubhead)
                .foregroundColor(.signal)

            Spacer()
        }
        .padding()
        .background(Color.signalSubtle)
        .cornerRadius(RemodlyRadius.medium)
    }
}

struct MeasurementRow: View {
    let label: String
    @Binding var value: Double
    let unit: String
    let isEditing: Bool

    @State private var editValue: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.remodlyBody)
                .foregroundColor(.ivory)

            Spacer()

            if isEditing {
                TextField("", text: $editValue)
                    .font(.remodlyBody)
                    .foregroundColor(.ivory)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
                    .padding(.horizontal, RemodlySpacing.sm)
                    .padding(.vertical, RemodlySpacing.xs)
                    .background(Color.ivorySubtle)
                    .cornerRadius(RemodlyRadius.small)
                    .overlay(
                        RoundedRectangle(cornerRadius: RemodlyRadius.small)
                            .stroke(isFocused ? Color.copper : Color.ivoryBorder, lineWidth: 1)
                    )
                    .focused($isFocused)
                    .onAppear { editValue = String(format: "%.1f", value) }
                    .onChange(of: editValue) { _, newValue in
                        if let doubleValue = Double(newValue) {
                            value = doubleValue
                        }
                    }
            } else {
                Text(String(format: "%.1f", value))
                    .font(.remodlyBody)
                    .fontWeight(.medium)
                    .foregroundColor(.copper)
            }

            Text(unit)
                .font(.remodlySubhead)
                .foregroundColor(.bodyText)
                .frame(width: 50, alignment: .leading)
        }
    }
}

struct CountRow: View {
    let label: String
    @Binding var count: Int
    let isEditing: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.remodlyBody)
                .foregroundColor(.ivory)

            Spacer()

            if isEditing {
                HStack(spacing: RemodlySpacing.sm) {
                    Button(action: { if count > 0 { count -= 1 } }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.copper)
                    }

                    Text("\(count)")
                        .font(.remodlyBody)
                        .fontWeight(.medium)
                        .foregroundColor(.ivory)
                        .frame(width: 30)

                    Button(action: { count += 1 }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.copper)
                    }
                }
            } else {
                Text("\(count)")
                    .font(.remodlyBody)
                    .fontWeight(.medium)
                    .foregroundColor(.copper)
            }
        }
    }
}

struct FixtureRow: View {
    let fixture: QuantitySheet.Fixture

    var body: some View {
        HStack {
            Image(systemName: fixture.type.icon)
                .foregroundColor(.copper)
                .frame(width: 24)

            Text(fixture.type.displayName)
                .font(.remodlyBody)
                .foregroundColor(.ivory)

            Spacer()

            Text("x\(fixture.count)")
                .font(.remodlyBody)
                .fontWeight(.medium)
                .foregroundColor(.copper)
        }
    }
}

// MARK: - Preview

// Preview requires CapturedRoom data from a real scan
#Preview {
    Text("QuantitySheetView Preview\n(requires CapturedRoom from scan)")
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.obsidian)
}
