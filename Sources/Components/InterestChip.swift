import SwiftUI

/// Selectable interest / filter chip with spring + haptic feedback.
struct InterestChip: View {
    let title: String
    let symbol: String?
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.selection()
            action()
        }) {
            HStack(spacing: 6) {
                if let symbol {
                    Image(systemName: symbol).font(.subheadline)
                }
                Text(title).font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? .white : .secondary)
            .background {
                if isSelected {
                    Capsule().fill(Theme.brandGradient)
                } else {
                    Capsule().strokeBorder(Theme.hairline, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

/// A larger tappable interest tile (used in onboarding).
struct InterestTile: View {
    let interest: Interest
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.selection()
            action()
        }) {
            VStack(spacing: 10) {
                Image(systemName: interest.symbol)
                    .font(.title2)
                    .foregroundStyle(isSelected ? AnyShapeStyle(Theme.brandSolid) : AnyShapeStyle(Color.secondary))
                Text(interest.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .glass(cornerRadius: Theme.Radius.md, strong: isSelected)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                        .strokeBorder(Theme.brandGradient, lineWidth: 1.5)
                }
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white, Theme.fuchsia)
                        .padding(8)
                        .transition(.scale)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
