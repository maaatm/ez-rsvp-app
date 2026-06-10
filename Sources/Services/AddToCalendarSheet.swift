import SwiftUI
import EventKit
import EventKitUI

/// Presents the system "Add Event" sheet, pre-filled from a revealed mystery so
/// the user can drop it straight onto their calendar. Mirrors `MapsLauncher` in
/// spirit — a thin, fail-soft bridge to a native iOS capability — but because
/// the editor needs an authorized store, request write access *before* you
/// present this (see `RevealedDetails.addToCalendar`).
struct AddToCalendarSheet: UIViewControllerRepresentable {
    let event: MysteryEvent
    let store: EKEventStore
    var onFinish: () -> Void

    /// Default duration when the event model carries no explicit end time.
    private static let defaultDuration: TimeInterval = 2 * 60 * 60

    func makeCoordinator() -> Coordinator { Coordinator(onFinish: onFinish) }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = store
        controller.editViewDelegate = context.coordinator
        controller.event = makeEvent()
        return controller
    }

    func updateUIViewController(_ controller: EKEventEditViewController, context: Context) {}

    private func makeEvent() -> EKEvent {
        let ek = EKEvent(eventStore: store)
        ek.title = event.title
        ek.startDate = event.eventTime
        ek.endDate = event.eventTime.addingTimeInterval(Self.defaultDuration)
        ek.location = "\(event.venueName), \(event.generalArea)"
        ek.notes = event.eventDescription
        ek.addAlarm(EKAlarm(relativeOffset: -60 * 60)) // nudge an hour before
        if let calendar = store.defaultCalendarForNewEvents { ek.calendar = calendar }
        return ek
    }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        let onFinish: () -> Void
        init(onFinish: @escaping () -> Void) { self.onFinish = onFinish }

        func eventEditViewController(_ controller: EKEventEditViewController,
                                     didCompleteWith action: EKEventEditViewAction) {
            if action == .saved { Haptics.notify(.success) }
            onFinish()
        }
    }
}
