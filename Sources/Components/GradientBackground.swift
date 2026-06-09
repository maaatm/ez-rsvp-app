import SwiftUI

/// Ambient app background: near-black base, drifting brand-colored aurora blobs,
/// and floating ticket / pin glyphs. Respects Reduce Motion.
struct GradientBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false

    private let glyphs = ["ticket.fill", "mappin.circle.fill", "sparkles", "ticket", "mappin"]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            // Aurora blobs
            blob(Theme.violet, size: 460)
                .offset(x: animate ? -120 : -150, y: animate ? -260 : -300)
            blob(Theme.fuchsia, size: 420)
                .offset(x: animate ? 160 : 180, y: animate ? -120 : -80)
            blob(Theme.cyan, size: 440)
                .offset(x: animate ? -80 : -40, y: animate ? 320 : 360)

            // Floating glyphs
            GeometryReader { geo in
                ForEach(0..<10, id: \.self) { i in
                    Image(systemName: glyphs[i % glyphs.count])
                        .font(.system(size: CGFloat(18 + (i % 4) * 12)))
                        .foregroundStyle(Theme.ink.opacity(0.035))
                        .position(
                            x: geo.size.width * positions[i].x,
                            y: geo.size.height * positions[i].y + (animate ? -16 : 16)
                        )
                        .animation(
                            reduceMotion ? nil :
                                .easeInOut(duration: Double(5 + i % 4))
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.3),
                            value: animate
                        )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }

    private func blob(_ color: Color, size: CGFloat) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: 120)
            .opacity(0.16)
    }

    private let positions: [(x: CGFloat, y: CGFloat)] = [
        (0.12, 0.18), (0.82, 0.10), (0.45, 0.30), (0.20, 0.55), (0.90, 0.48),
        (0.30, 0.78), (0.70, 0.70), (0.55, 0.92), (0.08, 0.88), (0.95, 0.85)
    ]
}

#Preview {
    GradientBackground()
}
