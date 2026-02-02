import SwiftUI

/// Shown before scanning to select room type
struct RoomTypeSelectionView: View {
    @Binding var selectedRoomType: RoomCapture.RoomType?
    let onContinue: () -> Void

    private let supportedTypes: [RoomCapture.RoomType] = [
        .bathroom, .kitchen, .utility
    ]

    var body: some View {
        VStack(spacing: RemodlySpacing.lg) {
            // Header
            VStack(spacing: RemodlySpacing.sm) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 48))
                    .foregroundColor(.copper)

                Text("What type of room?")
                    .font(.remodlyTitle1)
                    .foregroundColor(.ivory)

                Text("Select the room type for optimized scanning")
                    .font(.remodlyBody)
                    .foregroundColor(.bodyText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, RemodlySpacing.xl)

            // Room type grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: RemodlySpacing.md) {
                ForEach(supportedTypes, id: \.self) { roomType in
                    RoomTypeCard(
                        roomType: roomType,
                        isSelected: selectedRoomType == roomType
                    ) {
                        selectedRoomType = roomType
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            // Continue button
            RemodlyButton(
                title: "Start Scanning",
                icon: "arrow.right",
                isDisabled: selectedRoomType == nil
            ) {
                onContinue()
            }
            .padding(.horizontal)
            .padding(.bottom, RemodlySpacing.lg)
        }
        .background(Color.obsidian)
    }
}

struct RoomTypeCard: View {
    let roomType: RoomCapture.RoomType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: RemodlySpacing.sm) {
                Image(systemName: roomType.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .signal : .copper)

                Text(roomType.displayName)
                    .font(.remodlyHeadline)
                    .foregroundColor(isSelected ? .ivory : .bodyText)

                // Hint about windows
                if !roomType.typicallyHasWindows {
                    Text("Often windowless")
                        .font(.remodlyCaption)
                        .foregroundColor(.bodyText.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, RemodlySpacing.lg)
            .background(isSelected ? Color.copperSubtle : Color.tungsten)
            .cornerRadius(RemodlyRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: RemodlyRadius.large)
                    .stroke(isSelected ? Color.signal : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    RoomTypeSelectionView(
        selectedRoomType: .constant(.bathroom)
    ) {
        print("Continue tapped")
    }
}
