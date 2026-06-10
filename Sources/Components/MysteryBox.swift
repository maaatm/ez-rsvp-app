import SwiftUI

/// The signature mystery box — floats, glows, and pulses to build anticipation.
///
/// Styled to match the web app's `RSVPCard` in its locked state: a shadow-grey
/// rounded card with a soft pastel glow underneath and white glyphs, instead of
/// the previous glass/gradient-border treatment.
struct MysteryBox: View {
    var size: CGFloat = 180
    var glow: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floatUp = false
    @State private var pulse = false

    /// 24pt to match the web RSVPCard, scaled down for small inline uses.
    private var corner: CGFloat { min(size * 0.18, 24) }

    var body: some View {
        ZStack {
            // Soft pastel glow halo
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Theme.brandGradient)
                .frame(width: size, height: size)
                .blur(radius: size * 0.24)
                .opacity(glow ? (pulse ? 0.5 : 0.32) : 0.22)

            // The mystery card — shadow-grey, like the web RSVPCard's locked state.
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Theme.ink)
                .overlay(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(Theme.brandGradient.opacity(pulse ? 0.22 : 0.14))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                )
                .frame(width: size, height: size)
                .overlay {
                    HStack(spacing: size * 0.04) {
                        ForEach(0..<3, id: \.self) { _ in
                            Image(systemName: "questionmark")
                                .font(.system(size: size * 0.26, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                    .opacity(pulse ? 1 : 0.7)
                }
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                .shadow(color: Theme.ink.opacity(0.22), radius: size * 0.12, x: 0, y: size * 0.06)
        }
        .offset(y: floatUp ? -10 : 0)
        .accessibilityLabel("Mystery event, not yet revealed")
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) { floatUp = true }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}

#Preview {
    ZStack { GradientBackground(); MysteryBox() }
}
