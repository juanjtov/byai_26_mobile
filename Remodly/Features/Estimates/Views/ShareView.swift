import SwiftUI

struct ShareView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var shareLink: String?
    @State private var isGenerating = false
    @State private var isCopied = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "link.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Share with Homeowner")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Generate a secure link that allows the homeowner to view the design options and estimate.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let link = shareLink {
                    // Link display
                    VStack(spacing: 12) {
                        HStack {
                            Text(link)
                                .font(.system(.body, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Button(action: copyLink) {
                                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                                    .foregroundColor(isCopied ? .green : .blue)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)

                        // Share options
                        HStack(spacing: 16) {
                            ShareButton(icon: "message.fill", label: "Message", color: .green) {
                                shareViaMessages()
                            }

                            ShareButton(icon: "envelope.fill", label: "Email", color: .blue) {
                                shareViaEmail()
                            }

                            ShareButton(icon: "square.and.arrow.up", label: "More", color: .gray) {
                                shareViaSystem()
                            }
                        }
                    }
                    .padding()
                } else {
                    // Generate button
                    Button(action: generateShareLink) {
                        if isGenerating {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Generating...")
                            }
                        } else {
                            Text("Generate Share Link")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .disabled(isGenerating)
                    .padding(.horizontal)
                }

                Spacer()

                // Info
                VStack(alignment: .leading, spacing: 8) {
                    InfoItem(icon: "eye", text: "Homeowner can view 3 design options")
                    InfoItem(icon: "doc.text", text: "Includes estimate summary and PDF")
                    InfoItem(icon: "clock", text: "Link expires in 30 days")
                    InfoItem(icon: "lock.fill", text: "Secure, view-only access")
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func generateShareLink() {
        isGenerating = true

        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            shareLink = "https://share.remodly.com/v/abc123xyz"
            isGenerating = false
        }
    }

    private func copyLink() {
        guard let link = shareLink else { return }
        UIPasteboard.general.string = link
        isCopied = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied = false
        }
    }

    private func shareViaMessages() {
        // Implement Messages sharing
    }

    private func shareViaEmail() {
        // Implement Email sharing
    }

    private func shareViaSystem() {
        // Implement system share sheet
    }
}

struct ShareButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .cornerRadius(12)

                Text(label)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct InfoItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    ShareView()
}
