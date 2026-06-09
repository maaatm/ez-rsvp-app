import SwiftUI

/// Primary CTA: solid charcoal pill with white text — the web app's button.
struct PrimaryButtonStyle: ButtonStyle {
    var fullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, fullWidth ? 0 : 24)
            .background(Theme.ink, in: Capsule())
            .shadow(color: Theme.ink.opacity(0.22), radius: configuration.isPressed ? 4 : 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Secondary CTA: white pill, charcoal text, hairline border (web's outlined button).
struct SecondaryButtonStyle: ButtonStyle {
    var fullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.medium)
            .foregroundStyle(Theme.ink)
            .padding(.vertical, 16)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, fullWidth ? 0 : 24)
            .glass(cornerRadius: Theme.Radius.pill)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static func primary(fullWidth: Bool) -> PrimaryButtonStyle { PrimaryButtonStyle(fullWidth: fullWidth) }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
    static func secondary(fullWidth: Bool) -> SecondaryButtonStyle { SecondaryButtonStyle(fullWidth: fullWidth) }
}
