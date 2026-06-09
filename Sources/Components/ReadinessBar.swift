import SwiftUI

struct ReadinessBar: View {
    /// 0...1
    let value: Double
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.surfaceSunken)
                Capsule()
                    .fill(Theme.brandGradientHorizontal)
                    .frame(width: max(height, geo.size.width * value))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: value)
            }
        }
        .frame(height: height)
    }
}
