import SwiftUI

/// A real, venue-related photo for an event, with the event's SF Symbol glyph as
/// a graceful fallback while it loads or if the fetch fails (e.g. offline).
///
/// Shared by every revealed-event hero — the reveal room, the reveal ceremony
/// card, and the home page headline card — so they all resolve the image and
/// degrade to the glyph the same way. The photo URL itself comes from
/// `MysteryEvent.heroImageURL`.
struct EventHeroImage: View {
    let event: MysteryEvent
    /// Fixed width for a square/thumbnail use; when nil the image stretches to
    /// fill the available width (the default for full-width heroes).
    var width: CGFloat? = nil
    var height: CGFloat = 190
    var cornerRadius: CGFloat = Theme.Radius.md
    /// Point size for the fallback SF Symbol glyph.
    var fallbackGlyphSize: CGFloat = 56

    var body: some View {
        content
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
            )
    }

    @ViewBuilder
    private var content: some View {
        if let url = event.heroImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    ZStack { Theme.surfaceSunken; ProgressView() }
                case .failure:
                    fallback
                @unknown default:
                    fallback
                }
            }
        } else {
            fallback
        }
    }

    private var fallback: some View {
        ZStack {
            Theme.surfaceSunken
            Image(systemName: event.imageSymbol)
                .font(.system(size: fallbackGlyphSize))
                .foregroundStyle(Theme.brandSolid)
        }
    }
}
