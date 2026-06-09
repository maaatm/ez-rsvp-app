import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// The Social tab — friends, the FOMO activity feed, and persistent crews
/// (crews now live here since they're a standing social unit, not tied to one
/// event).
struct SocialView: View {
    @Environment(SessionStore.self) private var session
    @State private var showCreate = false
    @State private var showJoin = false
    @State private var showAddFriend = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Space.xl) {
                    friendsSection
                    activitySection
                    crewsSection
                }
                .padding(Theme.Space.lg)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Social")
            .sheet(isPresented: $showCreate) { CreateGroupSheet() }
            .sheet(isPresented: $showJoin) { JoinGroupSheet() }
            .sheet(isPresented: $showAddFriend) { AddFriendSheet() }
        }
    }

    // MARK: Friends

    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeader(title: "Friends",
                              subtitle: "\(session.friends.count) saying yes to mysteries")
                Button { showAddFriend = true } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.headline).foregroundStyle(Theme.brandGradient)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    Button { showAddFriend = true } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle().strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                    .foregroundStyle(Theme.hairline).frame(width: 52, height: 52)
                                Image(systemName: "plus").foregroundStyle(.secondary)
                            }
                            Text("Add").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    ForEach(session.friends) { friend in
                        NavigationLink {
                            FriendProfileView(user: friend)
                        } label: {
                            VStack(spacing: 6) {
                                AvatarView(user: friend, size: 52)
                                Text(friend.firstName).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            }
                            .frame(width: 64)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
            .scrollClipDisabled()
        }
    }

    // MARK: Activity feed

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Happening now")
            if session.activity.isEmpty {
                Text("Add friends to see what they're saying yes to.")
                    .font(.subheadline).foregroundStyle(.secondary)
            } else {
                ForEach(session.activity) { item in
                    NavigationLink {
                        FriendProfileView(user: item.user)
                    } label: {
                        ActivityRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Crews

    private var crewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeader(title: "Your crews")
                Spacer()
                Button { showJoin = true } label: {
                    Image(systemName: "link").font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Theme.violet)
                Button { showCreate = true } label: {
                    Label("New", systemImage: "plus").font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Theme.violet)
            }
            ForEach(session.groups) { crew in
                NavigationLink {
                    GroupDetailView(groupID: crew.id)
                } label: {
                    CrewRow(crew: crew, activeQuest: session.activeQuest(forCrew: crew.id),
                            isOwner: crew.ownerID == session.currentUser?.id)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct CrewRow: View {
    let crew: RSVPGroup
    let activeQuest: Quest?
    let isOwner: Bool

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: crew.symbol)
                    .font(.title2).foregroundStyle(Theme.brandGradient)
                    .frame(width: 52, height: 52).glass(cornerRadius: Theme.Radius.sm)
                VStack(alignment: .leading, spacing: 2) {
                    Text(crew.name).font(.headline).foregroundStyle(Theme.ink)
                    Text("\(crew.members.count) members").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if isOwner { Badge(text: "Owner", tint: Theme.violet) }
            }

            HStack {
                AvatarStack(users: crew.members.filter { $0.status == .going }.map(\.user))
                Spacer()
                if activeQuest != nil {
                    Badge(text: "On a mystery", systemImage: "sparkles", tint: Theme.fuchsia)
                } else {
                    Badge(text: "Idle", systemImage: "moon.zzz.fill", tint: .secondary)
                }
            }
        }
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.md)
        .gradientBorder(cornerRadius: Theme.Radius.md, lineWidth: 1)
    }
}

// MARK: - Add friend

private struct AddFriendSheet: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Add friends").font(.title2.weight(.bold))
                    Text("Find people you know and say yes to mysteries together.")
                        .font(.subheadline).foregroundStyle(.secondary)

                    if session.suggestedFriends.isEmpty {
                        Text("You've added everyone we suggested 🎉")
                            .font(.subheadline).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity).padding(.vertical, 24)
                    } else {
                        SectionHeader(title: "Suggested")
                        ForEach(session.suggestedFriends) { user in
                            HStack(spacing: 12) {
                                NavigationLink {
                                    FriendProfileView(user: user)
                                } label: {
                                    HStack(spacing: 12) {
                                        AvatarView(user: user, size: 44)
                                        VStack(alignment: .leading, spacing: 1) {
                                            HStack(spacing: 5) {
                                                Text(user.name).font(.subheadline.weight(.semibold))
                                                if user.isPrivateProfile {
                                                    Image(systemName: "lock.fill")
                                                        .font(.caption2).foregroundStyle(.secondary)
                                                }
                                            }
                                            Text(user.city).font(.caption).foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                Spacer()
                                Button {
                                    Haptics.impact(.light)
                                    withAnimation { session.addFriend(user) }
                                } label: {
                                    Label("Add", systemImage: "plus").font(.caption.weight(.bold))
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(Theme.brandGradient, in: Capsule())
                                        .foregroundStyle(.white)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(12)
                            .glass(cornerRadius: Theme.Radius.md)
                        }
                    }
                }
                .padding(Theme.Space.lg)
            }
            .background(GradientBackground())
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Crew create / join sheets

private struct CreateGroupSheet: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    private let suggestions = ["Friday Adventure Squad", "Rutgers Crew", "Random Friday Plans"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Create a crew").font(.title2.weight(.bold))
                    Text("A crew is your standing squad — start mysteries together whenever you're ready.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    TextField("Crew name…", text: $name)
                        .padding(.horizontal, 16).frame(height: 52)
                        .glass(cornerRadius: Theme.Radius.pill)

                    Text("Quick ideas").font(.caption).foregroundStyle(.secondary)
                    FlowLayout(spacing: 8) {
                        ForEach(suggestions, id: \.self) { s in
                            Button { name = s; Haptics.selection() } label: {
                                Text(s).font(.caption).foregroundStyle(.secondary)
                                    .padding(.horizontal, 12).padding(.vertical, 8)
                                    .glass(cornerRadius: Theme.Radius.pill)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button("Create crew") {
                        Task {
                            await session.createGroup(name: name)
                            Haptics.notify(.success)
                            dismiss()
                        }
                    }
                    .buttonStyle(.primary)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(Theme.Space.lg)
            }
            .background(GradientBackground())
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct JoinGroupSheet: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Join a crew").font(.title2.weight(.bold))
                    Text("Enter the invite code a friend shared with you.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    TextField("INVITE CODE", text: $code)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.system(.title3, design: .monospaced))
                        .padding(.horizontal, 16).frame(height: 52)
                        .glass(cornerRadius: Theme.Radius.pill)
                    if let error {
                        Text(error).font(.caption).foregroundStyle(.red)
                    }
                    Button("Join crew") {
                        Task {
                            do {
                                try await session.joinGroup(code: code)
                                Haptics.notify(.success)
                                dismiss()
                            } catch {
                                self.error = error.localizedDescription
                                Haptics.notify(.error)
                            }
                        }
                    }
                    .buttonStyle(.primary)
                    .disabled(code.count < 4)
                }
                .padding(Theme.Space.lg)
            }
            .background(GradientBackground())
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

/// Small UIKit pasteboard helper kept out of view bodies.
@MainActor
func UIPasteboardCopy(_ string: String) {
    #if canImport(UIKit)
    UIPasteboard.general.string = string
    #endif
}
