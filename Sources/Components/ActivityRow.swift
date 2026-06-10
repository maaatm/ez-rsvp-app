import SwiftUI

/// One friend-activity row for the social/FOMO feed. Pre-reveal items stay a
/// mystery ("said yes to a mystery"); revealed items show the actual adventure.
struct ActivityRow: View {
    @Environment(SessionStore.self) private var session
    let item: ActivityItem

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(user: item.user, size: 42)

            VStack(alignment: .leading, spacing: 2) {
                (Text(item.user.firstName).fontWeight(.semibold)
                    + Text(" \(item.headline)").foregroundStyle(.secondary))
                    .font(.subheadline)
                    .lineLimit(2)

                if item.isReveal, let event = session.event(id: item.revealedEventID ?? "") {
                    Label(event.title, systemImage: event.imageSymbol)
                        .font(.caption.weight(.medium)).foregroundStyle(Theme.violet).lineLimit(1)
                } else {
                    Text(item.detail).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            VStack(spacing: 6) {
                ZStack {
                    Circle().fill(Theme.violet.opacity(0.12)).frame(width: 36, height: 36)
                    Image(systemName: item.isReveal ? "party.popper.fill" : "questionmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.brandSolid)
                }
                Text(item.timeAgo).font(.caption2).foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .glass(cornerRadius: Theme.Radius.md)
    }
}
