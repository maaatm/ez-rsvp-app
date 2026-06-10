import SwiftUI

/// Your **public profile** — a read-only preview of exactly what other people see
/// when they open you: your picture, name, username, the mysteries you've said yes
/// to (as mysteries, no spoilers), and your crews. All the editing, preferences,
/// legal, and account actions live behind the gear in the top-right (`SettingsView`).
struct ProfileView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Space.lg) {
                    if let user = session.currentUser {
                        header(user)

                        Label("This is how others see your profile", systemImage: "eye")
                            .font(.caption).foregroundStyle(.secondary)

                        upcomingSection(user)
                        crewsSection(user)
                    }
                }
                .padding(Theme.Space.lg)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
    }

    // MARK: Header

    private func header(_ user: AppUser) -> some View {
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

            friendsPill(user)

            if user.isPrivateProfile {
                Badge(text: "Private profile", systemImage: "lock.fill", tint: .secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.lg, strong: true)
        .gradientBorder(cornerRadius: Theme.Radius.lg)
    }

    /// Tappable "X friends" stat that pushes the friends list.
    @ViewBuilder
    private func friendsPill(_ user: AppUser) -> some View {
        let friends = session.friends(forUser: user.id)
        NavigationLink {
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

    // MARK: Upcoming mysteries (future RSVPs)

    private func upcomingSection(_ user: AppUser) -> some View {
        let upcoming = session.upcomingMysteries(forUser: user.id)
        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Upcoming mysteries",
                          subtitle: "You said yes — the rest is a surprise")
            if upcoming.isEmpty {
                Text("You have no upcoming mysteries yet.")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.Space.lg)
                    .glass(cornerRadius: Theme.Radius.md)
            } else {
                ForEach(upcoming, id: \.event.id) { item in
                    HStack(spacing: 14) {
                        MysteryBox(size: 48, glow: false)
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

    // MARK: Crews (groups)

    private func crewsSection(_ user: AppUser) -> some View {
        let crews = session.crews(forUser: user.id)
        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Crews")
            if crews.isEmpty {
                Text("Not in any crews yet.")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.Space.lg)
                    .glass(cornerRadius: Theme.Radius.md)
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
}
