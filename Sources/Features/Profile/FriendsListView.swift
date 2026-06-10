import SwiftUI

/// A scrollable list of one person's friends. Each row pushes that friend's
/// profile. Shown from both your own profile and other people's, so anyone can
/// see who someone else is friends with.
struct FriendsListView: View {
    @Environment(SessionStore.self) private var session
    /// First name of whose friends these are — used in the empty state copy.
    let ownerName: String
    let friends: [AppUser]

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if friends.isEmpty {
                    emptyState
                } else {
                    ForEach(friends) { friend in
                        NavigationLink {
                            FriendProfileView(user: friend)
                        } label: {
                            row(friend)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Theme.Space.lg)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ friend: AppUser) -> some View {
        HStack(spacing: 14) {
            AvatarView(user: friend, size: 48)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(friend.name).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                    if friend.isPrivateProfile {
                        Image(systemName: "lock.fill").font(.caption2).foregroundStyle(.secondary)
                    }
                }
                Text("@\(friend.handle)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if friend.id != session.currentUser?.id, session.isFriend(friend) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.subheadline).foregroundStyle(.green)
            }
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
        }
        .padding(12)
        .glass(cornerRadius: Theme.Radius.md)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2").font(.largeTitle).foregroundStyle(Theme.brandSolid)
            Text("No friends yet").font(.headline)
            Text("\(ownerName) hasn't added any friends yet.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Space.xl)
        .glass(cornerRadius: Theme.Radius.lg)
    }
}
