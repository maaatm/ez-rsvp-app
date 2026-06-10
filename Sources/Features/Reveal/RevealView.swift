import SwiftUI
import MapKit
import EventKit

struct RevealView: View {
    @Environment(SessionStore.self) private var session
    let eventID: String

    enum Phase { case waiting, revealing, revealed }
    @State private var phase: Phase = .waiting

    private var event: MysteryEvent? { session.event(id: eventID) }
    private var group: RSVPGroup? { event.flatMap { session.crew(forEvent: $0.id) } }

    var body: some View {
        ZStack {
            if let event {
                Group {
                    switch phase {
                    case .waiting, .revealing:
                        WaitingRoom(event: event, group: group) {
                            phase = .revealing
                        }
                    case .revealed:
                        RevealedDetails(event: event, group: group)
                    }
                }

                // Ceremony overlay — only while revealing. A tap once the
                // animation finishes continues to the event details.
                if phase == .revealing {
                    RevealCeremony(event: event) {
                        // Lock the reveal in so it stays open everywhere, even
                        // if the real reveal time is still in the future (demo).
                        session.reveal(event.id)
                        withAnimation(.smooth) { phase = .revealed }
                    }
                    .transition(.opacity)
                }
            } else {
                ContentUnavailableView("Event not found", systemImage: "questionmark.folder")
            }
        }
        .navigationTitle("Reveal Room")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let event, session.isRevealed(event) { phase = .revealed }
        }
    }
}

// MARK: - Waiting room

private struct WaitingRoom: View {
    let event: MysteryEvent
    let group: RSVPGroup?
    var onReveal: () -> Void

    /// Demo override — when set, the countdown targets this instead of the real
    /// reveal time, so we can show the clock tick down before the ceremony.
    @State private var demoTarget: Date?

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Space.xl) {
                Badge(text: "Reveal room", systemImage: "bolt.fill", tint: Theme.violet)

                MysteryBox(size: 170)

                VStack(spacing: 12) {
                    Text("Your mystery unlocks in")
                        .font(.title3.weight(.bold))
                    CountdownView(target: demoTarget ?? event.revealTime, onComplete: onReveal)
                }

                Label("\(event.eventTime.formatted(style: .weekdayLong)) · \(event.eventTime.formatted(style: .time))",
                      systemImage: "clock")
                    .font(.caption).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // Who you're going with — visible before the reveal, even though
                // the event itself stays hidden.
                if let group {
                    HStack {
                        AvatarStack(users: group.members.filter { $0.status == .going }.map(\.user))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("\(group.goingCount) going").font(.subheadline.weight(.semibold))
                            Text(group.name).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "person.2.fill").foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .glass(cornerRadius: Theme.Radius.sm)
                } else {
                    HStack {
                        Image(systemName: "person.fill").foregroundStyle(.secondary)
                        Text("Going solo — invite a crew from Social")
                            .font(.caption).foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(14)
                    .glass(cornerRadius: Theme.Radius.sm)
                }

                TicketPaymentCard(event: event, group: group)

                VStack(alignment: .leading, spacing: 12) {
                    Label("Clues unlocked so far", systemImage: "magnifyingglass")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ClueList(event: event)
                }
                .padding(Theme.Space.lg)
                .glass(cornerRadius: Theme.Radius.md)

                // Demo trigger — drops the countdown to 3 seconds so we can watch
                // the clock tick down into the ceremony, rather than skipping it.
                VStack(spacing: 12) {
                    Text("Hackathon demo mode — don't wait for the real clock.")
                        .font(.caption).foregroundStyle(.secondary)
                    Button {
                        Haptics.impact(.medium)
                        withAnimation { demoTarget = Date.now.addingTimeInterval(3) }
                    } label: {
                        Label(demoTarget == nil ? "Reveal in 3 seconds" : "Counting down…",
                              systemImage: "party.popper.fill")
                    }
                    .buttonStyle(.primary)
                    .disabled(demoTarget != nil)
                }
                .padding(Theme.Space.lg)
                .overlay(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                    .foregroundStyle(Theme.hairline))
            }
            .padding(Theme.Space.lg)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Revealed details

private struct RevealedDetails: View {
    @Environment(SessionStore.self) private var session
    let event: MysteryEvent
    let group: RSVPGroup?
    @State private var showShare = false
    @State private var mapZoom = false
    @State private var showCalendar = false
    @State private var calendarStore: EKEventStore?

    private var attendees: [AppUser] {
        (group?.members.filter { $0.status == .going }.map(\.user)) ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Space.lg) {
                // Hero
                VStack(spacing: 14) {
                    Image(systemName: event.imageSymbol)
                        .font(.system(size: 64)).foregroundStyle(Theme.brandSolid)
                        .padding(.top, 8)
                    Badge(text: "You said yes — here it is", systemImage: "sparkles", tint: Theme.cyan)
                    Text(event.title)
                        .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                        .multilineTextAlignment(.center)
                    Text(event.eventDescription)
                        .font(.subheadline).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(Theme.Space.lg)
                .glass(cornerRadius: Theme.Radius.lg, strong: true)
                .gradientBorder(cornerRadius: Theme.Radius.lg)

                TicketPaymentCard(event: event, group: group)

                // Map
                VStack(alignment: .leading, spacing: 10) {
                    Label("The destination", systemImage: "mappin.and.ellipse")
                        .font(.headline)
                    BlurredMapView(event: event, zoomIn: mapZoom)
                        .frame(height: 220)
                }

                // Info grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    InfoTile(symbol: "clock", label: "When",
                             value: event.eventTime.formatted(style: .time),
                             sub: event.eventTime.formatted(style: .dayMonth))
                    InfoTile(symbol: "mappin", label: "Where",
                             value: event.venueName, sub: event.generalArea)
                    if let w = event.weather {
                        InfoTile(symbol: w.symbol, label: "Weather",
                                 value: "\(w.temp)°", sub: w.condition)
                    }
                    InfoTile(symbol: "person.2.fill", label: "Your group",
                             value: "\(attendees.count) friends", sub: group?.name ?? "attending")
                }

                // Attendees
                if !attendees.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Who's coming").font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(attendees) { user in
                                    VStack(spacing: 6) {
                                        AvatarView(user: user, size: 52)
                                        Text(user.firstName).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.Space.lg)
                    .glass(cornerRadius: Theme.Radius.md)
                }

                // Actions
                VStack(spacing: 12) {
                    Button {
                        MapsLauncher.open(event, using: mapsApp, directions: true)
                    } label: {
                        Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    }
                    .buttonStyle(.primary)

                    HStack(spacing: 12) {
                        Button {
                            addToCalendar()
                        } label: {
                            Label("Add to Calendar", systemImage: "calendar.badge.plus")
                                .frame(maxWidth: .infinity)
                                .lineLimit(1)
                        }
                        .buttonStyle(.secondary)

                        Button { showShare = true } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.secondary)
                    }
                }
            }
            .padding(Theme.Space.lg)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showShare) {
            ShareCardView(event: event, groupCount: attendees.count)
        }
        .sheet(isPresented: $showCalendar) {
            if let calendarStore {
                AddToCalendarSheet(event: event, store: calendarStore) {
                    showCalendar = false
                }
                .ignoresSafeArea()
            }
        }
        .onAppear {
            // Trigger the map zoom shortly after details appear.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { mapZoom = true }
            }
        }
    }

    private var mapsApp: MapsApp { session.currentUser?.mapsApp ?? .apple }

    /// Request write-only calendar access, then present the native add-event
    /// sheet. The editor needs an authorized store to save, so we ask first and
    /// reuse the same store. Denial fails soft — no sheet, no crash.
    private func addToCalendar() {
        Haptics.impact(.light)
        let store = EKEventStore()
        store.requestWriteOnlyAccessToEvents { granted, _ in
            DispatchQueue.main.async {
                guard granted else { return }
                calendarStore = store
                showCalendar = true
            }
        }
    }
}

/// Per-user ticket payment inside the reveal room. A crew assigns an event for
/// free, then each member pays for their own ticket here (solo plans arrive
/// already paid). Tapping through opens the Apple Pay checkout sheet.
private struct TicketPaymentCard: View {
    @Environment(SessionStore.self) private var session
    let event: MysteryEvent
    let group: RSVPGroup?
    @State private var showCheckout = false

    private var paid: Bool { session.hasPaid(event.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Your ticket", systemImage: "ticket.fill")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                Spacer()
                Text(event.price.ticketPriceText)
                    .font(.subheadline.weight(.bold)).foregroundStyle(Theme.ink)
            }

            if paid {
                Label("You're paid up — see you there", systemImage: "checkmark.seal.fill")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(group.map { "Everyone in \($0.name) pays for their own ticket." }
                        ?? "Pay your ticket to lock in your spot.")
                    .font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button { showCheckout = true } label: {
                    Label("Pay your ticket", systemImage: "creditcard.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.primary)
            }
        }
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.md)
        .sheet(isPresented: $showCheckout) {
            ApplePayCheckoutSheet(event: event, crewName: group?.name) {
                session.markPaid(event.id)
            }
        }
    }
}

private struct InfoTile: View {
    let symbol: String
    let label: String
    let value: String
    let sub: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: symbol)
                .font(.subheadline).foregroundStyle(Theme.brandSolid)
                .frame(width: 36, height: 36).glass(cornerRadius: 10)
            Text(label.uppercased()).font(.caption2.weight(.bold)).tracking(1).foregroundStyle(.secondary)
            Text(value).font(.subheadline.weight(.bold)).foregroundStyle(Theme.ink).lineLimit(1)
            Text(sub).font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glass(cornerRadius: Theme.Radius.md)
    }
}
