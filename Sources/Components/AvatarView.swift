import SwiftUI
import UIKit

struct AvatarView: View {
    let user: AppUser
    var size: CGFloat = 40
    @State private var localImage: UIImage?

    var body: some View {
        ZStack {
            avatarColor
            if let localImage {
                Image(uiImage: localImage).resizable().scaledToFill()
            } else if let remote = remoteURL {
                // Only genuine remote (http/https) photos go through AsyncImage.
                AsyncImage(url: remote) { image in
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
        .task(id: user.photoURL) { await loadLocalImage() }
    }

    private var initialsLabel: some View {
        Text(user.initials)
            .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
    }

    /// A remote (http/https) photo, if the user has one — handled by AsyncImage.
    private var remoteURL: URL? {
        guard let url = user.photoURL, !url.isFileURL else { return nil }
        return url
    }

    /// A locally-saved avatar, rebuilt against the *current* Documents directory.
    /// Saved photo URLs are absolute and embed the app's data-container UUID,
    /// which iOS rewrites between installs/restores — so a stored absolute path
    /// goes stale. We resolve by filename each time instead of trusting it, and
    /// return nil if the file isn't actually on disk (→ fall back to initials).
    private var localFileURL: URL? {
        guard let url = user.photoURL, url.isFileURL else { return nil }
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let resolved = docs.appendingPathComponent(url.lastPathComponent)
        return FileManager.default.fileExists(atPath: resolved.path) ? resolved : nil
    }

    /// Decodes a local avatar off the main thread — never via URLSession, so a
    /// missing file just shows initials instead of throwing a download error and
    /// hitching the UI.
    private func loadLocalImage() async {
        guard let fileURL = localFileURL else {
            localImage = nil
            return
        }
        let image = await Task.detached(priority: .userInitiated) {
            UIImage(contentsOfFile: fileURL.path)
        }.value
        localImage = image
    }

    /// Deterministic solid color per user (stable across launches), drawn from
    /// the saturated brand accents for good contrast with the white initials.
    private var avatarColor: Color {
        let palette = [Theme.violet, Theme.fuchsia, Theme.cyan]
        let seed = user.id.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        return palette[seed % palette.count]
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
