import Foundation

extension Date {
    func formatted(style: DateFormatStyle) -> String {
        let f = DateFormatter()
        switch style {
        case .dayMonth:
            f.dateFormat = "MMM d"
        case .weekdayLong:
            f.dateFormat = "EEEE, MMM d"
        case .time:
            f.dateFormat = "h:mm a"
        }
        return f.string(from: self)
    }
}

enum DateFormatStyle {
    case dayMonth      // "Jun 18"
    case weekdayLong   // "Friday, Jun 18"
    case time          // "7:00 PM"
}

/// A live countdown breakdown.
struct CountdownParts: Equatable {
    var days: Int
    var hours: Int
    var minutes: Int
    var seconds: Int
    var isComplete: Bool

    init(to target: Date, from now: Date = .now) {
        let remaining = max(0, target.timeIntervalSince(now))
        isComplete = remaining <= 0
        days = Int(remaining) / 86_400
        hours = (Int(remaining) % 86_400) / 3_600
        minutes = (Int(remaining) % 3_600) / 60
        seconds = Int(remaining) % 60
    }

    /// "2 Days 14 Hours" — for compact summaries.
    var humanShort: String {
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m \(seconds)s"
    }
}

func generateInviteCode() -> String {
    let chars = Array("ABCDEFGHJKMNPQRSTUVWXYZ23456789")
    return String((0..<6).map { _ in chars.randomElement()! })
}
