import SwiftUI

/// Real-time countdown. Drives off a `TimelineView` so it ticks every second
/// without a manual timer, and animates digit changes.
struct CountdownView: View {
    let target: Date
    var compact: Bool = false
    var onComplete: (() -> Void)? = nil

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let parts = CountdownParts(to: target, from: context.date)
            Group {
                if compact {
                    Text(parts.humanShort)
                        .font(.system(.title3, design: .rounded).weight(.bold).monospacedDigit())
                        .foregroundStyle(Theme.ink)
                } else {
                    HStack(spacing: 6) {
                        unit(parts.days, "Days")
                        colon
                        unit(parts.hours, "Hrs")
                        colon
                        unit(parts.minutes, "Min")
                        colon
                        unit(parts.seconds, "Sec")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .onChange(of: parts.isComplete) { _, done in
                if done { onComplete?() }
            }
        }
    }

    private var colon: some View {
        Text(":")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(.secondary.opacity(0.5))
            .offset(y: -8)
    }

    private func unit(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 6) {
            Text(String(format: "%02d", value))
                .font(.system(size: 28, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(Theme.ink)
                .frame(width: 54, height: 66)
                .glass(cornerRadius: Theme.Radius.sm, strong: true)
                .contentTransition(.numericText(countsDown: true))
                .animation(.snappy, value: value)
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(1.0)
                .lineLimit(1)
                .fixedSize()
        }
    }
}

#Preview {
    ZStack {
        GradientBackground()
        CountdownView(target: .now.addingTimeInterval(3 * 86_400 + 5000))
    }
}
