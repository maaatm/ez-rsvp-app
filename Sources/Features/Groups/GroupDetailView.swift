import SwiftUI

/// Crew detail. A crew is persistent; from here it can **start a mystery RSVP**
/// (matched to guardrail preferences) or, if it already has one, jump into the
/// reveal room.
struct GroupDetailView: View {
    @Environment(SessionStore.self) private var session
    let groupID: String
    @State private var copied = false
    @State private var showQuestSheet = false

    private var group: RSVPGroup? { session.group(id: groupID) }
    private var activeQuest: Quest? { session.activeQuest(forCrew: groupID) }

    var body: some View {
        ScrollView {
            if let group {
                VStack(spacing: Theme.Space.lg) {
                    header(group)
                    questSection(group)
                    invite(group)
                    readiness(group)
                    members(group)
                }
                .padding(Theme.Space.lg)
                .padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle(group?.name ?? "Crew")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showQuestSheet) {
            QuestPreferencesSheet(crewID: groupID)
        }
    }

    private func header(_ group: RSVPGroup) -> some View {
        VStack(spacing: 12) {
            Image(systemName: group.symbol)
                .font(.system(size: 36)).foregroundStyle(Theme.brandSolid)
                .frame(width: 72, height: 72).glass(cornerRadius: Theme.Radius.md)
            Text(group.name).font(.title2.weight(.bold))
            Text("\(group.members.count) members · \(group.goingCount) going")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.lg, strong: true)
        .gradientBorder(cornerRadius: Theme.Radius.lg)
    }

    @ViewBuilder
    private func questSection(_ group: RSVPGroup) -> some View {
        if let quest = activeQuest, let event = session.event(id: quest.eventID) {
            let revealed = session.isRevealed(event)
            VStack(spacing: 14) {
                Badge(text: revealed ? "Your crew's plan" : "Your crew's mystery",
                      systemImage: revealed ? "checkmark.seal.fill" : "sparkles",
                      tint: revealed ? Theme.cyan : Theme.violet)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 14) {
                    if revealed {
                        Image(systemName: event.imageSymbol)
                            .font(.title).foregroundStyle(Theme.brandSolid)
                            .frame(width: 56, height: 56)
                            .glass(cornerRadius: Theme.Radius.sm)
                    } else {
                        MysteryBox(size: 56, glow: false, animated: false)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        if revealed {
                            Text(event.title).font(.subheadline.weight(.bold))
                                .foregroundStyle(Theme.ink).lineLimit(1)
                        }
                        Text(revealed ? "Starts in" : "Reveals in")
                            .font(.caption).foregroundStyle(.secondary)
                        CountdownView(target: revealed ? event.eventTime : event.revealTime, compact: true)
                    }
                    Spacer()
                }
                if !session.hasPaid(event.id) {
                    PaymentDueBanner(event: event)
                }
                NavigationLink {
                    RevealView(eventID: event.id)
                } label: {
                    Label(revealed ? "Directions & full details" : "Open the reveal room",
                          systemImage: revealed ? "arrow.up.right" : "eye.fill")
                }
                .buttonStyle(.primary)
            }
            .padding(Theme.Space.lg)
            .glass(cornerRadius: Theme.Radius.md)
        } else {
            VStack(spacing: 12) {
                MysteryBox(size: 80, animated: false)
                Text("No mystery yet").font(.headline)
                Text("Set your crew's guardrails and we'll match you to something you'll love.")
                    .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                Button {
                    showQuestSheet = true
                } label: {
                    Label("Start a mystery RSVP", systemImage: "sparkles")
                }
                .buttonStyle(.primary)

                Text("Or browse Discover, open a mystery, and add it to this crew.")
                    .font(.caption).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(Theme.Space.lg)
            .glass(cornerRadius: Theme.Radius.md)
        }
    }

    private func invite(_ group: RSVPGroup) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "ticket.fill").foregroundStyle(Theme.brandSolid)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Invite friends").font(.subheadline.weight(.semibold))
                    Text("Code \(group.inviteCode)")
                        .font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
                }
                Spacer()
            }
            HStack(spacing: 10) {
                ShareLink(
                    item: group.inviteLink,
                    subject: Text("Join \(group.name) on e-z.rsvp"),
                    message: Text(group.inviteMessage)
                ) {
                    Label("Share invite", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.primary)

                Button {
                    UIPasteboardCopy(group.inviteLink.absoluteString)
                    copied = true
                    Haptics.notify(.success)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.headline)
                        .foregroundStyle(copied ? .green : Theme.ink)
                        .frame(width: 56, height: 56)
                        .glass(cornerRadius: Theme.Radius.pill)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.md)
    }

    private func readiness(_ group: RSVPGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Crew readiness").font(.headline)
                Spacer()
                Text("\(Int(group.readiness * 100))%")
                    .font(.title3.weight(.bold)).foregroundStyle(Theme.brandGradient)
            }
            ReadinessBar(value: group.readiness, height: 12)

            let me = group.members.first { $0.user.id == session.currentUser?.id }
            if let me {
                Toggle(isOn: Binding(
                    get: { me.isReady },
                    set: { newValue in
                        Task { await session.setReady(groupID: group.id, ready: newValue) }
                        Haptics.impact(.light)
                    }
                )) {
                    Label("I'm ready for the next adventure", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.medium))
                }
                .tint(Theme.fuchsia)
                .padding(.top, 4)
            }
        }
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.md)
    }

    private func members(_ group: RSVPGroup) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Members")
            ForEach(group.members) { member in
                // Resolve the current user's row to their live profile so edits
                // made in Settings (name, photo, privacy) show here too.
                let person = session.liveUser(member.user)
                NavigationLink {
                    FriendProfileView(user: person)
                } label: {
                    HStack(spacing: 12) {
                        AvatarView(user: person, size: 40)
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(spacing: 5) {
                                Text(person.name).font(.subheadline.weight(.semibold))
                                if person.id == group.ownerID {
                                    Image(systemName: "crown.fill").font(.caption2).foregroundStyle(.yellow)
                                }
                                if person.isPrivateProfile {
                                    Image(systemName: "lock.fill").font(.caption2).foregroundStyle(.secondary)
                                }
                            }
                            Text(member.status.label).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Label(member.isReady ? "Ready" : "Pending",
                              systemImage: member.isReady ? "checkmark.circle.fill" : "clock")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(member.isReady ? .green : .secondary)
                        Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
                    }
                    .padding(12)
                    .glass(cornerRadius: Theme.Radius.sm)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
