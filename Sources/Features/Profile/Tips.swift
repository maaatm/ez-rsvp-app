import TipKit

/// TipKit onboarding hints. Configured once at launch in `EZRsvpApp`.
struct RevealTip: Tip {
    var title: Text { Text("The reveal is the moment") }
    var message: Text? { Text("Open the reveal room near event time for a full-screen, confetti-soaked surprise. Then share the card.") }
    var image: Image? { Image(systemName: "sparkles") }
}

struct GroupTip: Tip {
    var title: Text { Text("Bring your crew") }
    var message: Text? { Text("Create a group and share the invite code — everyone discovers the mystery together.") }
    var image: Image? { Image(systemName: "person.2.fill") }
}
