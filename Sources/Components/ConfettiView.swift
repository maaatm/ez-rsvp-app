import SwiftUI

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat          // 0...1 of width
    var y: CGFloat          // 0...1 of height (start)
    var vx: CGFloat         // points/sec
    var vy: CGFloat         // points/sec (negative = up)
    var size: CGFloat
    var color: Color
    var spin: Double
    var lifetime: Double
}

/// GPU-friendly confetti rendered with Canvas. Physics is computed analytically
/// from elapsed time each frame (no per-frame state mutation), so it's smooth
/// and cheap. Bump `trigger` to fire a fresh burst.
struct ConfettiView: View {
    var trigger: Int
    var intensity: Int = 160

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pieces: [ConfettiPiece] = []
    @State private var startDate: Date = .now

    private let gravity: CGFloat = 900
    private let colors: [Color] = [Theme.violet, Theme.fuchsia, Theme.cyan, .white, Theme.peach]

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSince(startDate)
                Canvas { ctx, size in
                    for piece in pieces {
                        let dt = CGFloat(t)
                        let px = piece.x * size.width + piece.vx * dt
                        let py = piece.y * size.height + piece.vy * dt + 0.5 * gravity * dt * dt
                        let progress = t / piece.lifetime
                        guard progress < 1 else { continue }
                        let opacity = 1 - max(0, (progress - 0.6) / 0.4)

                        var rect = Path(
                            roundedRect: CGRect(x: -piece.size / 2, y: -piece.size / 2,
                                                width: piece.size, height: piece.size * 0.5),
                            cornerRadius: 1
                        )
                        let transform = CGAffineTransform(translationX: px, y: py)
                            .rotated(by: piece.spin * t)
                        rect = rect.applying(transform)
                        ctx.fill(rect, with: .color(piece.color.opacity(opacity)))
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .onChange(of: trigger) { _, _ in fire() }
    }

    private func fire() {
        guard !reduceMotion else { return }
        startDate = .now
        pieces = (0..<intensity).map { _ in
            let fromTop = Bool.random()
            return ConfettiPiece(
                x: CGFloat.random(in: 0...1),
                y: fromTop ? -0.05 : 0.5,
                vx: CGFloat.random(in: -260...260),
                vy: fromTop ? CGFloat.random(in: 40...160) : CGFloat.random(in: -680 ... -360),
                size: CGFloat.random(in: 7...13),
                color: colors.randomElement()!,
                spin: Double.random(in: -6...6),
                lifetime: Double.random(in: 2.2...3.4)
            )
        }
    }
}
