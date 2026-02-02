import SwiftUI

/// Bottom sheet asking user to confirm room has no windows/doors
struct NoOpeningsConfirmationSheet: View {
    let roomType: RoomCapture.RoomType
    let onConfirm: () -> Void
    let onContinueScanning: () -> Void

    var body: some View {
        VStack(spacing: RemodlySpacing.lg) {
            // Icon
            Image(systemName: "window.ceiling.closed")
                .font(.system(size: 48))
                .foregroundColor(.copper)
                .padding(.top, RemodlySpacing.lg)

            // Title
            Text("No Windows Detected")
                .font(.remodlyTitle2)
                .foregroundColor(.ivory)

            // Description
            Text("We haven't detected any windows in this \(roomType.displayName.lowercased()). Is that correct?")
                .font(.remodlyBody)
                .foregroundColor(.bodyText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Info callout
            HStack(alignment: .top, spacing: RemodlySpacing.sm) {
                Image(systemName: "info.circle")
                    .foregroundColor(.gold)

                Text("Many \(roomType.displayName.lowercased())s don't have windows. Confirming this allows you to complete the scan.")
                    .font(.remodlySubhead)
                    .foregroundColor(.bodyText)
            }
            .padding()
            .background(Color.ivorySubtle)
            .cornerRadius(RemodlyRadius.medium)
            .padding(.horizontal)

            Spacer()

            // Buttons
            VStack(spacing: RemodlySpacing.sm) {
                RemodlyButton(
                    title: "Yes, No Windows Here",
                    icon: "checkmark"
                ) {
                    onConfirm()
                }

                RemodlyButton(
                    title: "Keep Scanning",
                    style: .secondary,
                    icon: "camera.viewfinder"
                ) {
                    onContinueScanning()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, RemodlySpacing.lg)
        }
        .background(Color.obsidian)
    }
}

#Preview {
    NoOpeningsConfirmationSheet(
        roomType: .bathroom,
        onConfirm: { print("Confirmed") },
        onContinueScanning: { print("Continue scanning") }
    )
}
