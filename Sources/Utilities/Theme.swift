import SwiftUI

/// Central design tokens. Light-first, clean card UI mirroring the e-z.rsvp web
/// app: near-white lavender background, solid white cards with soft shadows,
/// charcoal ink text, and a soft pastel accent palette.
enum Theme {
    // Accent palette (pastels) — used as fills, chips, and gradient stops.
    static let violet = Color(red: 0.616, green: 0.475, blue: 0.737) // #9D79BC purple
    static let fuchsia = Color(red: 0.549, green: 0.627, blue: 0.843) // #8CA0D7 periwinkle
    static let cyan = Color(red: 0.569, green: 0.769, blue: 0.949)   // #91C4F2 sky blue
    static let peach = Color(red: 0.988, green: 0.843, blue: 0.678)  // #FCD7AD warm accent

    /// Solid brand accent — replaces `brandGradient` on icons and the default
    /// avatar so glyphs render in one flat color instead of a gradient.
    static let brandSolid = violet

    // Ink (text)
    static let ink = Color(red: 0.153, green: 0.161, blue: 0.196)        // #272932 primary text
    static let inkSecondary = Color(red: 0.420, green: 0.447, blue: 0.502) // muted slate

    // Surfaces (light)
    static let background = Color(red: 0.957, green: 0.961, blue: 0.973) // #F4F5F8 app background
    static let surface = Color.white                                     // card fill
    static let surfaceStrong = Color.white                               // elevated card fill
    static let surfaceSunken = Color(red: 0.933, green: 0.941, blue: 0.961) // #EEF0F5 nested chips/fields
    static let hairline = Color.black.opacity(0.07)
    static let cardShadow = Color.black.opacity(0.06)

    // Gradients — reserved for hero moments (avatars, mystery box, reveal).
    static let brandGradient = LinearGradient(
        colors: [violet, fuchsia, cyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let brandGradientHorizontal = LinearGradient(
        colors: [violet, fuchsia, cyan],
        startPoint: .leading,
        endPoint: .trailing
    )

    static func ambientGradient(_ scheme: ColorScheme) -> RadialGradient {
        RadialGradient(
            colors: [violet.opacity(0.12), .clear],
            center: .top,
            startRadius: 0,
            endRadius: 520
        )
    }

    // Spacing scale (8pt rhythm)
    enum Space {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let sm: CGFloat = 12
        static let md: CGFloat = 20
        static let lg: CGFloat = 28
        static let pill: CGFloat = 999
    }
}

extension Color {
    /// App-wide tinted shadow color.
    static let brandGlow = Theme.violet.opacity(0.35)
}
