import SwiftUI

/// Another person's profile. Shows their upcoming mysteries (as mysteries — no
/// spoilers) and the crews they're in. Gated by the privacy setting: a private
/// profile is only visible to friends.
struct FriendProfileView: View {
    @Environment(SessionStore.self) private var session
    let user: AppUser

    private var isSelf: Bool { user.id == session.currentUser?.id }
    private var canView: Bool { session.canViewProfile(of: user) }
    private var upcoming: [(event: MysteryEvent, crew: RSVPGroup)] {
        session.upcomingMysteries(forUser: user.id)
    }
    private var crews: [RSVPGroup] { session.crews(forUser: user.id) }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Space.lg) {
                header
                if canView {
                    upcomingSection
                    crewsSection
                } else {
                    lockedCard
                }
            }
            .padding(Theme.Space.lg)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(isSelf ? "You" : user.firstName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 12) {
            AvatarView(user: user, size: 92)
            VStack(spacing: 2) {
                Text(user.name).font(.title2.weight(.bold))
                Text("@\(user.handle)")
                    .font(.subheadline.weight(.medium)).foregroundStyle(Theme.violet)
            }
            if let bio = user.displayBio {
                Text(bio)
                    .font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Label(user.city, systemImage: "mappin.and.ellipse")
                .font(.subheadline).foregroundStyle(.secondary)

            // Friends are part of what a private profile hides — only show the
            // list to people who can actually view this profile (you, friends,
            // or anyone if it's public).
            if canView {
                friendsPill
            }

            if user.isPrivateProfile {
                Badge(text: "Private profile", systemImage: "lock.fill", tint: .secondary)
            }

            // For a private non-friend the locked card below carries its own
            // "Add friend" button, so only show the header friend action when
            // the profile is actually viewable — otherwise it'd appear twice.
            if !isSelf && canView {
                if session.isFriend(user) {
                    Label("Friends", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 18).padding(.vertical, 10)
                        .glass(cornerRadius: Theme.Radius.pill)
                } else {
                    Button {
                        Haptics.impact(.light)
                        withAnimation { session.addFriend(user) }
                    } label: {
                        Label("Add friend", systemImage: "person.badge.plus")
                    }
                    .buttonStyle(.primary(fullWidth: false))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.lg, strong: true)
        .gradientBorder(cornerRadius: Theme.Radius.lg)
    }

    /// Tappable "X friends" stat that pushes this person's friends list — so you
    /// can browse who they know.
    private var friendsPill: some View {
        let friends = session.friends(forUser: user.id)
        return NavigationLink {
            FriendsListView(ownerName: user.firstName, friends: friends)
        } label: {
            Label("\(friends.count) \(friends.count == 1 ? "friend" : "friends")",
                  systemImage: "person.2.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .glass(cornerRadius: Theme.Radius.pill)
        }
        .buttonStyle(.plain)
        .padding(.top, 2)
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Upcoming mysteries",
                          subtitle: "They said yes — the rest is a surprise")
            if upcoming.isEmpty {
                Text(isSelf ? "You have no upcoming mysteries yet."
                            : "No upcoming mysteries yet.")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.Space.lg)
                    .glass(cornerRadius: Theme.Radius.md)
            } else {
                ForEach(upcoming, id: \.event.id) { item in
                    HStack(spacing: 14) {
                        MysteryBox(size: 48, glow: false, animated: false)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mystery").font(.subheadline.weight(.semibold))
                            Text("\(item.event.eventTime.formatted(style: .weekdayLong)) · \(item.crew.name)")
                                .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        CountdownView(target: item.event.revealTime, compact: true)
                    }
                    .padding(14)
                    .glass(cornerRadius: Theme.Radius.md)
                }
            }
        }
    }

    private var crewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Crews")
            if crews.isEmpty {
                Text("Not in any crews yet.")
                    .font(.subheadline).foregroundStyle(.secondary)
            } else {
                ForEach(crews) { crew in
                    NavigationLink {
                        GroupDetailView(groupID: crew.id)
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: crew.symbol)
                                .font(.title3).foregroundStyle(Theme.brandSolid)
                                .frame(width: 44, height: 44).glass(cornerRadius: Theme.Radius.sm)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(crew.name).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                                Text("\(crew.members.count) members").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .glass(cornerRadius: Theme.Radius.md)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var lockedCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill").font(.largeTitle).foregroundStyle(Theme.brandSolid)
            Text("\(user.firstName)'s profile is private").font(.headline)
            Text("Add them as a friend to see their mysteries and crews.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button {
                Haptics.impact(.light)
                withAnimation { session.addFriend(user) }
            } label: {
                Label("Add friend", systemImage: "person.badge.plus")
            }
            .buttonStyle(.primary(fullWidth: false))
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Space.xl)
        .glass(cornerRadius: Theme.Radius.lg)
    }
}
