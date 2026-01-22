import SwiftUI

struct EstimateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var estimate: Estimate?
    @State private var isLoading = true
    @State private var showShare = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Generating estimate...")
                            .foregroundColor(.secondary)
                    }
                } else if let estimate = estimate {
                    estimateContent(estimate)
                } else {
                    Text("Failed to generate estimate")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Estimate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }

                if estimate != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { showShare = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showShare) {
                ShareView()
            }
            .task {
                await loadEstimate()
            }
        }
    }

    private func estimateContent(_ estimate: Estimate) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Summary card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Estimate")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(formatCurrency(estimate.grandTotal))
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }

                    Divider()

                    HStack {
                        SummaryColumn(
                            label: "Labor",
                            value: formatCurrency(estimate.laborTotal)
                        )
                        SummaryColumn(
                            label: "Materials",
                            value: formatCurrency(estimate.materialsTotal)
                        )
                        SummaryColumn(
                            label: "Allowances",
                            value: "\(formatCurrency(estimate.finishAllowanceLow)) - \(formatCurrency(estimate.finishAllowanceHigh))"
                        )
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)

                // Sections
                ForEach(estimate.sections) { section in
                    EstimateSectionView(section: section)
                }

                // Assumptions
                if !estimate.assumptions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Assumptions")
                            .font(.headline)

                        ForEach(estimate.assumptions, id: \.self) { assumption in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(assumption)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }

                // Exclusions
                if !estimate.exclusions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exclusions")
                            .font(.headline)

                        ForEach(estimate.exclusions, id: \.self) { exclusion in
                            HStack(alignment: .top) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text(exclusion)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }

                // Actions
                VStack(spacing: 12) {
                    Button(action: generatePDF) {
                        Label("Download PDF", systemImage: "doc.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: { showShare = true }) {
                        Label("Share with Homeowner", systemImage: "person.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top)
            }
            .padding()
        }
    }

    private func loadEstimate() async {
        // Simulate API call
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // Sample estimate data
        estimate = Estimate(
            id: UUID().uuidString,
            projectId: "proj_1",
            roomCaptureId: "capture_1",
            quantitySheetId: "qty_1",
            stylePresetId: "sophisticated",
            version: 1,
            sections: [
                EstimateSection(
                    id: "1",
                    name: "Demo & Prep",
                    lineItems: [
                        EstimateLineItem(id: "1", description: "Remove existing fixtures", quantity: 1, unit: "LS", unitPrice: 800, total: 800, category: .labor),
                        EstimateLineItem(id: "2", description: "Tile removal", quantity: 186, unit: "SF", unitPrice: 3.50, total: 651, category: .labor)
                    ],
                    subtotal: 1451
                ),
                EstimateSection(
                    id: "2",
                    name: "Rough Plumbing",
                    lineItems: [
                        EstimateLineItem(id: "3", description: "Rough-in plumbing", quantity: 1, unit: "LS", unitPrice: 2500, total: 2500, category: .labor),
                        EstimateLineItem(id: "4", description: "Plumbing materials", quantity: 1, unit: "LS", unitPrice: 600, total: 600, category: .material)
                    ],
                    subtotal: 3100
                )
            ],
            laborTotal: 8500,
            materialsTotal: 3200,
            finishAllowanceLow: 4000,
            finishAllowanceHigh: 8000,
            grandTotal: 18700,
            assumptions: [
                "Standard bathroom layout",
                "No structural modifications required",
                "Existing plumbing in good condition"
            ],
            exclusions: [
                "Permit fees",
                "Asbestos or lead abatement",
                "Electrical upgrades beyond code requirements"
            ],
            pdfUrl: nil,
            shareToken: nil,
            shareUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        isLoading = false
    }

    private func generatePDF() {
        // Implement PDF generation
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

struct SummaryColumn: View {
    let label: String
    let value: String

    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EstimateSectionView: View {
    let section: EstimateSection
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(section.name)
                        .font(.headline)
                    Spacer()
                    Text(formatCurrency(section.subtotal))
                        .fontWeight(.medium)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                ForEach(section.lineItems) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.description)
                                .font(.subheadline)
                            Text("\(String(format: "%.1f", item.quantity)) \(item.unit) × \(formatCurrency(item.unitPrice))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(formatCurrency(item.total))
                            .font(.subheadline)
                    }
                    .padding(.leading)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    EstimateView()
}
