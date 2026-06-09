import SwiftUI

struct OnboardingView: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var step = 0
    @State private var interests: Set<Interest> = []
    @State private var budget: PriceTier = .moderate
    @State private var radius: Double = 15
    @State private var availability: Set<String> = ["Fri", "Sat"]

    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<3) { i in
                    Capsule()
                        .fill(i <= step ? AnyShapeStyle(Theme.brandGradient) : AnyShapeStyle(Theme.surfaceSunken))
                        .frame(width: i == step ? 28 : 8, height: 8)
                        .animation(.spring, value: step)
                }
            }
            .padding(.top, 12)
            .opacity(step == 0 ? 0 : 1)

            Spacer(minLength: 0)

            Group {
                switch step {
                case 0: welcome
                case 1: interestsStep
                default: preferencesStep
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

            Spacer(minLength: 0)

            // CTA
            VStack(spacing: 12) {
                Button(action: advance) {
                    Text(ctaTitle)
                }
                .buttonStyle(.primary)
                .disabled(step == 1 && interests.isEmpty)
                .opacity(step == 1 && interests.isEmpty ? 0.5 : 1)

                if step > 0 {
                    Button("Back") { withAnimation(.smooth) { step -= 1 } }
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, Theme.Space.lg)
            .padding(.bottom, Theme.Space.lg)
        }
    }

    private var ctaTitle: String {
        switch step {
        case 0: return "Get started"
        case 1: return interests.isEmpty ? "Pick at least one" : "Continue"
        default: return "Find my mystery"
        }
    }

    private func advance() {
        Haptics.impact(.light)
        if step < 2 {
            withAnimation(.smooth) { step += 1 }
        } else {
            session.completeOnboarding(
                interests: Array(interests),
                budget: budget,
                radius: radius,
                availability: Array(availability)
            )
            // When shown as a sheet ("Edit preferences"), close it. At first
            // run this is a no-op and RootView advances to the auth screen.
            dismiss()
        }
    }

    // MARK: Steps

    private var welcome: some View {
        VStack(spacing: Theme.Space.xl) {
            MysteryBox(size: 150)
            AnimatedWelcomeText()
            Text("RSVP to a mystery experience before you know what it is. Get clues. Bring friends. The reveal is everything.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Space.xl)
        }
    }

    private var interestsStep: some View {
        VStack(spacing: Theme.Space.lg) {
            stepHeader("What are you into?", "We'll match you to experiences you'll love — without spoiling the surprise.")
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Interest.allCases) { interest in
                    InterestTile(interest: interest, isSelected: interests.contains(interest)) {
                        if interests.contains(interest) { interests.remove(interest) }
                        else { interests.insert(interest) }
                    }
                }
            }
            .padding(.horizontal, Theme.Space.lg)
        }
    }

    private var preferencesStep: some View {
        VStack(alignment: .leading, spacing: Theme.Space.xl) {
            stepHeader("A few preferences", "Helps us pick the right mystery for you.")

            VStack(alignment: .leading, spacing: 12) {
                Text("Budget").font(.headline)
                HStack(spacing: 10) {
                    ForEach(PriceTier.allCases, id: \.self) { tier in
                        InterestChip(title: tier.rawValue, symbol: nil, isSelected: budget == tier) {
                            budget = tier
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Travel radius").font(.headline)
                    Spacer()
                    Text("\(Int(radius)) mi").font(.subheadline.weight(.bold)).foregroundStyle(Theme.violet)
                }
                Slider(value: $radius, in: 5...50, step: 5).tint(Theme.fuchsia)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("When are you usually free?").font(.headline)
                HStack(spacing: 6) {
                    ForEach(days, id: \.self) { day in
                        dayChip(day)
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Space.lg)
    }

    /// Equal-width, uppercase day toggle for a clean, uniform row.
    private func dayChip(_ day: String) -> some View {
        let active = availability.contains(day)
        return Button {
            Haptics.selection()
            if active { availability.remove(day) } else { availability.insert(day) }
        } label: {
            Text(day.uppercased())
                .font(.caption2.weight(.bold))
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(
                    active ? AnyShapeStyle(Theme.brandGradient) : AnyShapeStyle(Theme.surface),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .foregroundStyle(active ? .white : .secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Theme.hairline, lineWidth: active ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func stepHeader(_ title: String, _ subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, Theme.Space.lg)
    }
}

/// Sequenced "Say yes first." → "Find out later." headline.
private struct AnimatedWelcomeText: View {
    @State private var showFirst = false
    @State private var showSecond = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 4) {
            Text("Say yes first.")
                .opacity(showFirst ? 1 : 0)
                .offset(y: showFirst ? 0 : 16)
            Text("Find out later.")
                .foregroundStyle(Theme.brandGradient)
                .opacity(showSecond ? 1 : 0)
                .offset(y: showSecond ? 0 : 16)
        }
        .font(.system(size: 40, weight: .heavy, design: .rounded))
        .multilineTextAlignment(.center)
        .onAppear {
            guard !reduceMotion else { showFirst = true; showSecond = true; return }
            withAnimation(.spring(response: 0.6).delay(0.2)) { showFirst = true }
            withAnimation(.spring(response: 0.6).delay(1.0)) { showSecond = true }
        }
    }
}

