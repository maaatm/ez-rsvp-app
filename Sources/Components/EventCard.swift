import SwiftUI

/// Mystery card for the feed. Reveals only category, date, difficulty, general
/// region, and (optionally) a match score — never the venue.
///
/// Styled to match the web app's `RSVPCard`: a full-bleed pastel color wash
/// (varied per card) softened by a translucent white overlay, rounded 24pt
/// corners with a soft shadow, frosted-white pills up top, and a live countdown
/// to the reveal with muted meta along the bottom.
struct EventCard: View {
    let event: MysteryEvent
    var topReason: String? = nil
    /// Mystery mode — hides the category badge and glyph so the surprise holds.
    var hideCategory: Bool = false

    private let corner: CGFloat = 24

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top row: category pill (hidden in mystery mode to hold the surprise).
            if !hideCategory {
                HStack(alignment: .top) {
                    frostedPill(event.category.rawValue, systemImage: event.category.symbol)
                    Spacer(minLength: 8)
                }
            }

            Spacer(minLength: 18)

            // Bottom block: eyebrow + big mystery title + muted meta.
            VStack(alignment: .leading, spacing: 6) {
                Text("REVEALS IN")
                    .font(.caption2.weight(.bold)).tracking(1.6)
                    .foregroundStyle(Theme.ink.opacity(0.55))
                revealCountdown

                HStack(spacing: 6) {
                    Image(systemName: "calendar").font(.caption2)
                    Text(event.eventTime.formatted(style: .dayMonth))
                    Text("·")
                    Image(systemName: "mappin.and.ellipse").font(.caption2)
                    Text(event.generalArea).lineLimit(1)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink.opacity(0.72))
                .padding(.top, 2)

                HStack(spacing: 8) {
                    Label(event.difficulty.rawValue, systemImage: "gauge.with.dots.needle.50percent")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.ink.opacity(0.72))
                    Spacer(minLength: 8)
                    Text(event.price.rawValue)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Theme.ink)
                }
                .padding(.top, 2)

                if let topReason {
                    Label(topReason, systemImage: "sparkles")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.6),
                                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .padding(.top, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
        .padding(20)
        .background {
            ZStack {
                wash
                Color.white.opacity(0.34)
                // Faint category watermark for depth (decorative, sits behind text).
                Image(systemName: hideCategory ? "questionmark.diamond.fill" : event.category.symbol)
                    .font(.system(size: 150, weight: .black))
                    .foregroundStyle(Color.white.opacity(0.16))
                    .rotationEffect(.degrees(-12))
                    .offset(x: 84, y: 56)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color.white.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: Theme.ink.opacity(0.10), radius: 22, x: 0, y: 14)
        .contentShape(Rectangle())
    }

    /// Live countdown to the mystery's reveal, styled as the card's big title.
    /// Ticks every second off a `TimelineView`; once the reveal lands it flips
    /// to a "live" label instead of negative time.
    private var revealCountdown: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let parts = CountdownParts(to: event.revealTime, from: context.date)
            Text(parts.isComplete ? "It's live now" : countdownText(parts))
                .font(.system(size: 23, weight: .heavy, design: .rounded).monospacedDigit())
                .tracking(-0.4)
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.numericText(countsDown: true))
                .animation(.snappy, value: parts.seconds)
        }
    }

    /// "12d 14:03:22" while days remain, otherwise "14:03:22".
    private func countdownText(_ p: CountdownParts) -> String {
        let hms = String(format: "%02d:%02d:%02d", p.hours, p.minutes, p.seconds)
        return p.days > 0 ? "\(p.days)d \(hms)" : hms
    }

    /// A stable pseudo-random pastel per card, hashed from the event id — so the
    /// color varies card to card but stays put across scrolls and redraws.
    /// Derived from the id (not the category), so it never leaks the hidden
    /// category in mystery mode.
    private var wash: Color {
        let palette = [Theme.violet, Theme.fuchsia, Theme.cyan, Theme.peach]
        let seed = event.id.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        return palette[seed % palette.count]
    }

    /// Frosted-white capsule, matching the web RSVPCard's `.pill`.
    private func frostedPill(_ text: String, systemImage: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage).font(.caption2.weight(.bold))
            Text(text).font(.caption.weight(.bold)).lineLimit(1)
        }
        .foregroundStyle(Theme.ink)
        .padding(.horizontal, 11).padding(.vertical, 7)
        .background(Color.white.opacity(0.84), in: Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.7), lineWidth: 1))
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

/// Attention banner for a group event the current user hasn't paid for yet.
/// Crews assign an event for free and each member pays their own ticket in the
/// reveal room — this nudges them to finish that.
struct PaymentDueBanner: View {
    let event: MysteryEvent
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "creditcard.fill").font(.title3).foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 1) {
                Text("Payment due").font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                if !compact {
                    Text("Pay your \(event.price.ticketPriceText) ticket in the reveal room")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
            if compact {
                Text(event.price.ticketPriceText)
                    .font(.subheadline.weight(.bold)).foregroundStyle(.orange)
            }
        }
        .padding(compact ? 10 : 12)
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous)
            .strokeBorder(Color.orange.opacity(0.45), lineWidth: 1))
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
