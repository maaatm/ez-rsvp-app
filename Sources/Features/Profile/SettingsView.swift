import SwiftUI
import TipKit

/// Everything that *isn't* your public profile: profile customization, your
/// interests, matching preferences, privacy, about & legal, and the sign-out /
/// delete-account actions. Reached from the gear in the top-right of `ProfileView`.
struct SettingsView: View {
    @Environment(SessionStore.self) private var session
    @State private var showOnboarding = false
    @State private var showEditProfile = false
    @State private var showDeleteConfirm = false
    private let revealTip = RevealTip()

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Space.lg) {
                if let user = session.currentUser {
                    // Profile customization
                    Button { showEditProfile = true } label: {
                        Label("Edit profile", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.primary)

                    TipView(revealTip)
                        .tipBackground(Theme.surfaceStrong)

                    // Interests
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Your interests")
                        FlexInterests(interests: user.interests)
                    }

                    // Prefs
                    VStack(spacing: 0) {
                        row("dollarsign.circle", "Budget", user.budget.rawValue)
                        Divider().overlay(Theme.hairline)
                        row("location.circle", "Travel radius", "\(Int(user.radiusMiles)) miles")
                        Divider().overlay(Theme.hairline)
                        row("calendar", "Free days", user.availability.joined(separator: ", "))
                        Divider().overlay(Theme.hairline)
                        mapsRow(current: user.mapsApp)
                    }
                    .padding(.horizontal, Theme.Space.lg)
                    .glass(cornerRadius: Theme.Radius.md)

                    // Privacy
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: Binding(
                            get: { user.isPrivateProfile },
                            set: { session.setPrivate($0); Haptics.selection() }
                        )) {
                            Label("Private profile", systemImage: "lock.fill")
                                .font(.subheadline.weight(.medium))
                        }
                        .tint(Theme.fuchsia)
                        Text("When on, only friends can see your mysteries and crews.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(Theme.Space.lg)
                    .glass(cornerRadius: Theme.Radius.md)

                    // About & legal
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "About & legal")
                        VStack(spacing: 0) {
                            legalRow("doc.plaintext", "Terms of Service", page: .termsOfService)
                            Divider().overlay(Theme.hairline)
                            legalRow("hand.raised.fill", "Privacy Policy", page: .privacyPolicy)
                            Divider().overlay(Theme.hairline)
                            legalRow("checkmark.shield.fill", "Safety & Trust", page: .safetyTrust)
                            Divider().overlay(Theme.hairline)
                            legalRow("questionmark.circle.fill", "Support", page: .support)
                        }
                        .padding(.horizontal, Theme.Space.lg)
                        .glass(cornerRadius: Theme.Radius.md)
                    }

                    // Actions
                    VStack(spacing: 12) {
                        Button { showOnboarding = true } label: {
                            Label("Edit preferences", systemImage: "slider.horizontal.3")
                        }
                        .buttonStyle(.secondary)

                        Button {
                            Haptics.impact(.medium)
                            session.signOut()
                        } label: {
                            Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .foregroundStyle(Theme.ink)
                        .glass(cornerRadius: Theme.Radius.pill)

                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete account", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .foregroundStyle(.red)
                        .glass(cornerRadius: Theme.Radius.pill)
                        .confirmationDialog(
                            "Delete your account?",
                            isPresented: $showDeleteConfirm,
                            titleVisibility: .visible
                        ) {
                            Button("Delete account", role: .destructive) {
                                Haptics.notify(.warning)
                                Task { await session.deleteAccount() }
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("This permanently deletes your account and all your data. This can't be undone.")
                        }
                    }
                }
            }
            .padding(Theme.Space.lg)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showOnboarding) {
            NavigationStack { OnboardingView() }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
        }
    }

    /// A tappable row that pushes one of the policy / support pages.
    private func legalRow(_ symbol: String, _ title: String, page: LegalPage) -> some View {
        NavigationLink {
            page
        } label: {
            HStack {
                Label(title, systemImage: symbol)
                    .font(.subheadline).foregroundStyle(Theme.ink)
                Spacer()
                Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.secondary)
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func row(_ symbol: String, _ label: String, _ value: String) -> some View {
        HStack {
            Label(label, systemImage: symbol).font(.subheadline)
            Spacer()
            Text(value).font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
        }
        .padding(.vertical, 14)
    }

    /// Tappable row to pick the preferred maps app.
    private func mapsRow(current: MapsApp) -> some View {
        Menu {
            Picker("Preferred maps app", selection: Binding(
                get: { current },
                set: { session.setPreferredMaps($0); Haptics.selection() }
            )) {
                ForEach(MapsApp.allCases) { app in
                    Label(app.rawValue, systemImage: app.symbol).tag(app)
                }
            }
        } label: {
            HStack {
                Label("Maps app", systemImage: "map")
                    .font(.subheadline).foregroundStyle(Theme.ink)
                Spacer()
                Text(current.rawValue)
                    .font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            .padding(.vertical, 14)
        }
    }
}

/// Simple wrapping interest display.
private struct FlexInterests: View {
    let interests: [Interest]
    var body: some View {
        if interests.isEmpty {
            Text("No interests yet").font(.subheadline).foregroundStyle(.secondary)
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(interests) { interest in
                    Label(interest.rawValue, systemImage: interest.symbol)
                        .font(.caption.weight(.medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .glass(cornerRadius: Theme.Radius.pill)
                }
            }
        }
    }
}
