import SwiftUI

/// Ambient app background: near-black base, soft brand-colored aurora glows, and
/// faint floating ticket / pin glyphs.
///
/// Deliberately **static**. This view sits behind the entire app (`RootView`),
/// so anything animated here runs forever on every screen and keeps the GPU from
/// ever idling — which was the app's main energy drain. Two changes keep it cheap:
///
/// 1. The aurora is drawn with `RadialGradient`s instead of blurred circles. A
///    gradient from a tinted color out to clear gives the same soft glow as the
///    old `Circle().blur(radius: 120)` but as a single shader fill, with none of
///    the per-frame multi-tap Gaussian blur cost.
/// 2. Nothing animates, and the whole thing is flattened with `.drawingGroup()`,
///    so the compositor rasterizes it once and reuses that bitmap at rest.
struct GradientBackground: View {
    private let glyphs = ["ticket.fill", "mappin.circle.fill", "sparkles", "ticket", "mappin"]

    var body: some View {
        ZStack {
            Theme.background

            // Aurora glows — radial gradients stand in for the old blurred blobs.
            aurora(Theme.violet, size: 700).offset(x: -135, y: -280)
            aurora(Theme.fuchsia, size: 640).offset(x: 170, y: -100)
            aurora(Theme.cyan, size: 680).offset(x: -60, y: 340)

            // Faint floating glyphs — purely decorative texture, now static.
            GeometryReader { geo in
                ForEach(0..<10, id: \.self) { i in
                    Image(systemName: glyphs[i % glyphs.count])
                        .font(.system(size: CGFloat(18 + (i % 4) * 12)))
                        .foregroundStyle(Theme.ink.opacity(0.035))
                        .position(
                            x: geo.size.width * positions[i].x,
                            y: geo.size.height * positions[i].y
                        )
                }
            }
        }
        .ignoresSafeArea()
        // Flatten the static layers into a single cached bitmap so the compositor
        // stops re-drawing the background once it's on screen.
        .drawingGroup()
        .allowsHitTesting(false)
    }

    /// Soft circular glow: a radial gradient from the tinted color out to clear,
    /// matching the falloff of the old blurred-circle blob at a fraction of the cost.
    private func aurora(_ color: Color, size: CGFloat) -> some View {
        RadialGradient(
            colors: [color.opacity(0.18), color.opacity(0.05), .clear],
            center: .center,
            startRadius: 0,
            endRadius: size / 2
        )
        .frame(width: size, height: size)
    }

    private let positions: [(x: CGFloat, y: CGFloat)] = [
        (0.12, 0.18), (0.82, 0.10), (0.45, 0.30), (0.20, 0.55), (0.90, 0.48),
        (0.30, 0.78), (0.70, 0.70), (0.55, 0.92), (0.08, 0.88), (0.95, 0.85)
    ]
}

#Preview {
    GradientBackground()
}
