import SwiftUI

// MARK: - Ticket pricing

extension PriceTier {
    /// A representative per-person ticket price for the tier. The mystery model
    /// only carries a `$` / `$$` / `$$$` band, so checkout maps each band to a
    /// concrete amount to show on the Apple Pay sheet.
    var ticketPrice: Double {
        switch self {
        case .budget: return 25
        case .moderate: return 45
        case .premium: return 85
        }
    }

    /// The per-person price formatted as USD, e.g. "$45.00".
    var ticketPriceText: String {
        ticketPrice.formatted(.currency(code: "USD"))
    }
}

/// An Apple Pay–style checkout you complete **before** an RSVP is created.
/// Payment now gates adding a mystery to a solo or crew plan — but the event
/// itself stays hidden, so the sheet shows only the price, date, and region.
///
/// Demo note: this simulates the Apple Pay authorization (Face ID → done) and
/// never charges a card, matching the app's MockBackend conventions.
struct ApplePayCheckoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    let event: MysteryEvent
    /// Name of the crew this ticket joins, or `nil` for a solo adventure.
    let crewName: String?
    /// Called once payment is authorized — wire this to create the RSVP.
    let onPaid: () -> Void

    private enum Phase { case review, authorizing, done }
    @State private var phase: Phase = .review

    private var total: Double { event.price.ticketPrice }

    var body: some View {
        Group {
            switch phase {
            case .review: reviewContent
            case .authorizing: authorizingContent
            case .done: doneContent
            }
        }
        .padding(Theme.Space.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .presentationDetents([.fraction(0.74), .large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(phase != .review)
    }

    // MARK: Review

    private var reviewContent: some View {
        VStack(spacing: Theme.Space.lg) {
            applePayHeader
            summaryCard
            methodCard
            Spacer(minLength: 8)
            payButton
            Text("Demo checkout · your card is never charged")
                .font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var applePayHeader: some View {
        HStack(spacing: 4) {
            Image(systemName: "apple.logo")
            Text("Pay").fontWeight(.semibold)
        }
        .font(.title3)
        .foregroundStyle(Theme.ink)
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MYSTERY EXPERIENCE")
                .font(.caption2.weight(.bold)).tracking(1.5).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Image(systemName: "questionmark.diamond.fill").foregroundStyle(Theme.brandSolid)
                Text("Revealed on the day")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
            }
            HStack(spacing: 14) {
                fact("calendar", event.eventTime.formatted(style: .dayMonth))
                fact("mappin.and.ellipse", event.generalArea)
            }
            Divider().overlay(Theme.hairline)
            HStack(spacing: 6) {
                Image(systemName: crewName == nil ? "person.fill" : "person.3.fill")
                    .font(.caption).foregroundStyle(Theme.violet)
                Text(crewName.map { "1 ticket · with \($0)" } ?? "1 ticket · going solo")
                    .font(.caption.weight(.medium)).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.md)
    }

    private var methodCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "creditcard.fill").font(.title3).foregroundStyle(Theme.ink)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Apple Pay").font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                    Text("Visa  •••• 4242").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
            }
            .padding(.vertical, 12)
            Divider().overlay(Theme.hairline)
            HStack {
                Text("Pay e-z.rsvp").font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Text(money(total)).font(.title3.weight(.bold)).foregroundStyle(Theme.ink)
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.md)
    }

    private var payButton: some View {
        Button { authorize() } label: {
            HStack(spacing: 6) {
                Text("Buy with")
                Image(systemName: "apple.logo")
                Text("Pay")
            }
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.black, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: Authorizing / Done

    private var authorizingContent: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "faceid")
                .font(.system(size: 64))
                .foregroundStyle(Theme.ink)
                .symbolEffect(.pulse, options: .repeating)
            Text("Confirm with Face ID").font(.headline)
            Text("Double-click the side button")
                .font(.subheadline).foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var doneContent: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72)).foregroundStyle(.green)
                .transition(.scale.combined(with: .opacity))
            Text("Done").font(.title2.weight(.bold))
            Text("\(money(total)) paid").font(.subheadline).foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Actions

    private func authorize() {
        Haptics.impact(.medium)
        withAnimation(.smooth) { phase = .authorizing }
        Task {
            try? await Task.sleep(for: .seconds(1.3))
            Haptics.notify(.success)
            withAnimation(.smooth) { phase = .done }
            try? await Task.sleep(for: .seconds(0.9))
            onPaid()
            dismiss()
        }
    }

    private func money(_ amount: Double) -> String {
        amount.formatted(.currency(code: "USD"))
    }

    private func fact(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: symbol).font(.caption)
            Text(text).font(.caption).lineLimit(1)
        }
        .foregroundStyle(.secondary)
    }
}
