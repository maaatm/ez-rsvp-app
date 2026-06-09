import SwiftUI

/// The signature mystery box — floats, glows, and pulses to build anticipation.
struct MysteryBox: View {
    var size: CGFloat = 180
    var glow: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floatUp = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Glow halo
            RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                .fill(Theme.brandGradient)
                .frame(width: size, height: size)
                .blur(radius: 44)
                .opacity(glow ? (pulse ? 0.5 : 0.32) : 0.22)

            // The box
            RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                .fill(Theme.surfaceStrong)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                        .fill(Theme.brandGradient.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                        .strokeBorder(Theme.brandGradient, lineWidth: 1.5)
                )
                .frame(width: size, height: size)
                .overlay {
                    HStack(spacing: size * 0.04) {
                        ForEach(0..<3, id: \.self) { _ in
                            Image(systemName: "questionmark")
                                .font(.system(size: size * 0.26, weight: .black, design: .rounded))
                                .foregroundStyle(Theme.brandGradient)
                        }
                    }
                    .opacity(pulse ? 1 : 0.65)
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
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
