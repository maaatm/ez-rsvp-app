import SwiftUI

/// Guardrail preferences before starting a mystery RSVP. The user sets
/// constraints (price ceiling, distance, energy) — never the event itself — so
/// the surprise survives while the match quality rises.
struct QuestPreferencesSheet: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss

    /// nil = solo quest. Otherwise the crew starting the RSVP.
    let crewID: String?
    var onStarted: ((Quest) -> Void)? = nil

    @State private var prefs = RSVPPreferences()
    @State private var noMatch = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Space.xl) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(crewID == nil ? "Start a mystery" : "Start a crew mystery")
                            .font(.title2.weight(.bold))
                        Text("Set the guardrails. We'll match you to something you'll love — you just won't know what until reveal day.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }

                    // Price ceiling
                    section("Spend up to") {
                        HStack(spacing: 10) {
                            ForEach(PriceTier.allCases, id: \.self) { tier in
                                InterestChip(title: tier.rawValue, symbol: nil,
                                             isSelected: prefs.priceCeiling == tier) {
                                    prefs.priceCeiling = tier
                                }
                            }
                        }
                    }

                    // Max distance
                    section("Stay within") {
                        HStack {
                            Slider(value: $prefs.maxDistance, in: 5...50, step: 5).tint(Theme.fuchsia)
                            Text("\(Int(prefs.maxDistance)) mi")
                                .font(.subheadline.weight(.bold)).foregroundStyle(Theme.violet)
                                .frame(width: 52, alignment: .trailing)
                        }
                    }

                    // Energy
                    section("Energy level") {
                        VStack(spacing: 4) {
                            Slider(value: $prefs.adventurousness, in: 0...1).tint(Theme.violet)
                            HStack {
                                Text("Chill").font(.caption).foregroundStyle(.secondary)
                                Spacer()
                                Text("Adventurous").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }

                    if noMatch {
                        Label("Nothing matches those guardrails right now — loosen one and try again.",
                              systemImage: "exclamationmark.triangle.fill")
                            .font(.caption).foregroundStyle(.orange)
                    }

                    Button {
                        if let quest = session.startQuest(crewID: crewID, preferences: prefs) {
                            Haptics.notify(.success)
                            onStarted?(quest)
                            dismiss()
                        } else {
                            noMatch = true
                            Haptics.notify(.warning)
                        }
                    } label: {
                        Label("Find our mystery", systemImage: "sparkles")
                    }
                    .buttonStyle(.primary)
                }
                .padding(Theme.Space.lg)
            }
            .background(GradientBackground())
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            if let user = session.currentUser {
                prefs.maxDistance = user.radiusMiles
                prefs.priceCeiling = user.budget
            }
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content()
        }
    }
}
