import SwiftUI

struct AvatarView: View {
    let user: AppUser
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Theme.brandGradient
            if let url = user.photoURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    initialsLabel
                }
            } else {
                initialsLabel
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1))
        .accessibilityLabel(user.name)
    }

    private var initialsLabel: some View {
        Text(user.initials)
            .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
    }
}

/// Overlapping avatar stack with an overflow pill.
struct AvatarStack: View {
    let users: [AppUser]
    var max: Int = 5
    var size: CGFloat = 34

    var body: some View {
        let shown = Array(users.prefix(max))
        let overflow = users.count - shown.count
        HStack(spacing: -size * 0.32) {
            ForEach(shown) { user in
                AvatarView(user: user, size: size)
            }
            if overflow > 0 {
                Text("+\(overflow)")
                    .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                    .frame(width: size, height: size)
                    .background(Theme.surfaceSunken, in: Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1))
            }
        }
    }
}
