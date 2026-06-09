import Foundation
import UserNotifications

/// Local notifications for clue drops, RSVP confirmations, group activity, and
/// the reveal-day "It's time." nudge. (Push via FCM would slot in behind the
/// same intents in production.)
@MainActor
final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let center = UNUserNotificationCenter.current()

    @discardableResult
    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func confirmRSVP(eventReveal: Date) {
        schedule(
            title: "You're in. 🎟️",
            body: "You've joined a mystery experience. Clues drop soon…",
            after: 1
        )
    }

    func notifyNewClue() {
        schedule(title: "New clue unlocked", body: "A new clue about your mystery just dropped.", after: 1)
    }

    func notifyGroupActivity(_ name: String) {
        schedule(title: "Group activity", body: "\(name) joined your RSVP group.", after: 1)
    }

    /// Schedule the dramatic reveal-day notification.
    func scheduleReveal(at date: Date, title: String) {
        let interval = date.timeIntervalSinceNow
        guard interval > 0 else { return }
        schedule(title: "It's time. ✨", body: "Your mystery is ready to reveal. Open e-z.rsvp.", after: interval)
    }

    /// Schedule clue drops on a daily cadence leading up to the reveal.
    func scheduleClueDrops(for event: MysteryEvent) {
        for clue in event.clues where clue.unlocksDaysBefore > 0 {
            let fire = event.revealTime.addingTimeInterval(-Double(clue.unlocksDaysBefore) * 86_400)
            let interval = fire.timeIntervalSinceNow
            guard interval > 0 else { continue }
            schedule(title: "New clue unlocked", body: clue.text, after: interval)
        }
    }

    private func schedule(title: String, body: String, after interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, interval), repeats: false)
        center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))
    }
}
