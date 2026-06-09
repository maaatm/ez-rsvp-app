import SwiftUI

/// Mystery card for the feed. Reveals only category, date, difficulty, general
/// region, and (optionally) a match score — never the venue.
struct EventCard: View {
    let event: MysteryEvent
    var matchScore: Double? = nil
    var topReason: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header band
            ZStack {
                Theme.brandGradient.opacity(0.22)
                Image(systemName: event.category.symbol)
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.brandGradient)
            }
            .frame(height: 110)
            .overlay(alignment: .topLeading) {
                Badge(text: event.category.rawValue, tint: event.category.tint)
                    .padding(10)
            }
            .overlay(alignment: .topTrailing) {
                if let matchScore {
                    Badge(text: "\(Int(matchScore * 100))% match", systemImage: "sparkles", tint: Theme.cyan)
                        .padding(10)
                }
            }

            // Body
            VStack(alignment: .leading, spacing: 10) {
                Text("MYSTERY EXPERIENCE")
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Image(systemName: "questionmark.diamond.fill").foregroundStyle(Theme.brandGradient)
                    Text("Revealed on the day").font(.headline)
                }

                HStack(spacing: 14) {
                    metric("calendar", event.eventTime.formatted(style: .dayMonth))
                    metric("mappin.and.ellipse", event.generalArea)
                }
                HStack(spacing: 14) {
                    metric("gauge.with.dots.needle.50percent", event.difficulty.rawValue, tint: event.difficulty.tint)
                    Text(event.price.rawValue).font(.subheadline.weight(.bold)).foregroundStyle(Theme.ink)
                }

                if let topReason {
                    Text(topReason)
                        .font(.caption)
                        .foregroundStyle(Theme.violet)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.violet.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(16)
        }
        .glass(cornerRadius: Theme.Radius.md)
        .gradientBorder(cornerRadius: Theme.Radius.md, lineWidth: 1)
        .contentShape(Rectangle())
    }

    private func metric(_ symbol: String, _ text: String, tint: Color = .secondary) -> some View {
        HStack(spacing: 5) {
            Image(systemName: symbol).font(.caption)
            Text(text).font(.caption).lineLimit(1)
        }
        .foregroundStyle(tint == .secondary ? AnyShapeStyle(Color.secondary) : AnyShapeStyle(tint))
    }
}

/// Small pill badge.
struct Badge: View {
    let text: String
    var systemImage: String? = nil
    var tint: Color = Theme.violet

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage { Image(systemName: systemImage).font(.caption2) }
            Text(text).font(.caption2.weight(.semibold))
        }
        .padding(.horizontal, 10).padding(.vertical, 5)
        .foregroundStyle(Theme.ink)
        .background(tint.opacity(0.85), in: Capsule())
        .overlay(Capsule().strokeBorder(Theme.ink.opacity(0.08), lineWidth: 0.5))
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.title3.weight(.bold))
            if let subtitle {
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
