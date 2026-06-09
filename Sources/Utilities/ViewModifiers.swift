import SwiftUI

// MARK: - Glassmorphism

/// Solid white "card" surface with a soft drop shadow — the web app's card look.
/// (Name kept as `glass` for call-site stability across the app.)
struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat = Theme.Radius.md
    var strong: Bool = false

    func body(content: Content) -> some View {
        content
            // Fill sits BEHIND the content so it never intercepts taps meant for
            // interactive children (buttons, toggles, etc.).
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
                    .allowsHitTesting(false)
            )
            // Shadow applied to the already-clipped shape so it renders outside.
            .shadow(color: Theme.cardShadow,
                    radius: strong ? 22 : 10,
                    x: 0, y: strong ? 12 : 5)
    }
}

// MARK: - Gradient border

struct GradientBorderModifier: ViewModifier {
    var cornerRadius: CGFloat = Theme.Radius.md
    var lineWidth: CGFloat = 1.5

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Theme.brandGradient, lineWidth: lineWidth)
                .allowsHitTesting(false)
        )
    }
}

extension View {
    func glass(cornerRadius: CGFloat = Theme.Radius.md, strong: Bool = false) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius, strong: strong))
    }

    func gradientBorder(cornerRadius: CGFloat = Theme.Radius.md, lineWidth: CGFloat = 1.5) -> some View {
        modifier(GradientBorderModifier(cornerRadius: cornerRadius, lineWidth: lineWidth))
    }

    /// Soft brand glow shadow for hero elements.
    func brandGlow(radius: CGFloat = 24) -> some View {
        shadow(color: .brandGlow, radius: radius, x: 0, y: 8)
    }
}

// MARK: - Gradient foreground helper

extension View {
    func gradientForeground() -> some View {
        self.overlay(Theme.brandGradient).mask(self)
    }
}
