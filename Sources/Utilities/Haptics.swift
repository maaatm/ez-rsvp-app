import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Thin wrapper around UIKit haptics so call sites stay clean and the rest of
/// the app compiles on any platform (no-ops where UIKit is unavailable).
enum Haptics {
    static func impact(_ style: ImpactStyle = .medium) {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: style.uiStyle)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    static func notify(_ type: NotificationType) {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type.uiType)
        #endif
    }

    static func selection() {
        #if canImport(UIKit)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    enum ImpactStyle {
        case light, medium, heavy, soft, rigid
        #if canImport(UIKit)
        var uiStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            case .soft: return .soft
            case .rigid: return .rigid
            }
        }
        #endif
    }

    enum NotificationType {
        case success, warning, error
        #if canImport(UIKit)
        var uiType: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success: return .success
            case .warning: return .warning
            case .error: return .error
            }
        }
        #endif
    }
}
