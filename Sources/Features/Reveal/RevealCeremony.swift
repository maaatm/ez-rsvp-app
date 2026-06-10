import SwiftUI

/// Full-screen cinematic reveal:
/// darken → shake → glow charge → particle burst (heavy haptic) → 3D flip → done.
struct RevealCeremony: View {
    let event: MysteryEvent
    /// Called when the user taps to leave the finished reveal for the details.
    var onContinue: () -> Void

    enum Stage { case idle, darken, shake, charge, burst, flip, done }

    @State private var stage: Stage = .idle
    @State private var flipAngle: Double = 0
    @State private var shakeOffset: CGFloat = 0
    @State private var confettiTrigger = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if stage != .idle {
                // Darkening scrim (60% — preserves foreground legibility)
                Color.black.opacity(0.92).ignoresSafeArea()
                    .overlay(
                        RadialGradient(
                            colors: [Theme.violet.opacity(stage == .charge || stage == .burst ? 0.4 : 0.12), .clear],
                            center: .center, startRadius: 0, endRadius: 420
                        ).ignoresSafeArea()
                    )

                // Shockwave on burst
                if stage == .burst {
                    Circle().strokeBorder(.white.opacity(0.6), lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .scaleEffect(8)
                        .opacity(0)
                        .animation(.easeOut(duration: 1), value: stage)
                }

                flipCard
                    .offset(x: shakeOffset)

                ConfettiView(trigger: confettiTrigger)

                // Once the reveal finishes, a tap anywhere continues to details.
                if stage == .done {
                    VStack {
                        Spacer()
                        Label("Tap anywhere to see the details", systemImage: "hand.tap.fill")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.bottom, 60)
                            .transition(.opacity)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if stage == .done {
                Haptics.impact(.light)
                onContinue()
            }
        }
        .onAppear { run() }
    }

    // MARK: 3D flip card

    private var flipCard: some View {
        ZStack {
            // FRONT — mystery
            faceContainer {
                VStack(spacing: 18) {
                    Image(systemName: "questionmark")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.brandSolid)
                        .scaleEffect(stage == .charge ? 1.15 : 1)
                        .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: stage)
                    Text(stageCaption)
                        .font(.caption.weight(.semibold)).tracking(2)
                        .foregroundStyle(Theme.inkSecondary)
                }
            }
            .opacity(flipAngle < 90 ? 1 : 0)
            .rotation3DEffect(.degrees(flipAngle), axis: (x: 0, y: 1, z: 0))

            // BACK — revealed
            faceContainer {
                VStack(spacing: 14) {
                    EventHeroImage(event: event, height: 150, fallbackGlyphSize: 60)
                    Text("YOU SAID YES TO").font(.caption2.weight(.bold)).tracking(2).foregroundStyle(Theme.violet)
                    Text(event.title)
                        .font(.system(.title, design: .rounded).weight(.heavy))
                        .multilineTextAlignment(.center)
                    Text(event.venueName).font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
            }
            .opacity(flipAngle < 90 ? 0 : 1)
            .rotation3DEffect(.degrees(flipAngle - 180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: 300, height: 420)
    }

    private func faceContainer<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .frame(width: 300, height: 420)
            .glass(cornerRadius: Theme.Radius.lg, strong: true)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                    .fill(Theme.brandGradient.opacity(stage == .charge || stage == .burst ? 0.25 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                    .strokeBorder(Theme.brandGradient, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
            .brandGlow(radius: stage == .charge ? 50 : 24)
    }

    private var stageCaption: String {
        switch stage {
        case .shake: return "SOMETHING'S HAPPENING…"
        case .charge: return "GET READY…"
        default: return "YOUR MYSTERY AWAITS"
        }
    }

    // MARK: Sequence

    private func run() {
        if reduceMotion {
            stage = .flip
            flipAngle = 180
            confettiTrigger += 1
            Haptics.notify(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation { stage = .done }
            }
            return
        }

        Task { @MainActor in
            stage = .darken
            try? await Task.sleep(for: .milliseconds(500))

            // Shake
            stage = .shake
            Haptics.impact(.rigid)
            withAnimation(.easeInOut(duration: 0.07).repeatCount(6, autoreverses: true)) {
                shakeOffset = 10
            }
            try? await Task.sleep(for: .milliseconds(450))
            // Smoothly settle back to dead center (never snap/teleport).
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                shakeOffset = 0
            }
            try? await Task.sleep(for: .milliseconds(550))

            // Charge / glow
            stage = .charge
            Haptics.impact(.medium)
            try? await Task.sleep(for: .milliseconds(1000))

            // Burst
            stage = .burst
            Haptics.impact(.heavy)
            Haptics.notify(.success)
            confettiTrigger += 1
            try? await Task.sleep(for: .milliseconds(250))

            // Flip
            stage = .flip
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                flipAngle = 180
            }
            try? await Task.sleep(for: .milliseconds(900))

            withAnimation { stage = .done }
        }
    }
}
