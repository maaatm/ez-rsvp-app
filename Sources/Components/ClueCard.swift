import SwiftUI

struct ClueCard: View {
    let clue: Clue
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isUnlocked ? clue.symbol : "lock.fill")
                .font(.subheadline)
                .foregroundStyle(isUnlocked ? AnyShapeStyle(Theme.brandSolid) : AnyShapeStyle(Color.secondary))
                .frame(width: 24)

            Text(isUnlocked ? clue.text : "Locked clue — unlocks soon")
                .font(.subheadline)
                .foregroundStyle(isUnlocked ? Theme.ink : .secondary)
                .blur(radius: isUnlocked ? 0 : 4)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glass(cornerRadius: Theme.Radius.sm)
        .overlay {
            if !isUnlocked {
                RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Theme.hairline)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isUnlocked ? "Clue: \(clue.text)" : "Locked clue")
    }
}

/// Animated stack of clue cards (used on Home + Reveal waiting room).
struct ClueList: View {
    let event: MysteryEvent

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(event.clues.enumerated()), id: \.element.id) { index, clue in
                ClueCard(clue: clue, isUnlocked: event.isClueUnlocked(clue))
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .animation(.spring(response: 0.4).delay(Double(index) * 0.06), value: clue.id)
            }
        }
    }
}
