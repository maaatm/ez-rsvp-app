import Foundation

struct GroupMember: Identifiable, Codable, Hashable {
    var id: String { user.id }
    var user: AppUser
    var status: RSVPStatus
    var isReady: Bool
}

/// A **Crew** — a persistent social unit. It exists independently of any event;
/// a crew *starts* a mystery RSVP (`Quest`) when it's ready for an adventure.
struct RSVPGroup: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var symbol: String // SF Symbol representing the crew
    var ownerID: String
    var inviteCode: String
    var members: [GroupMember]

    var goingCount: Int { members.filter { $0.status == .going }.count }

    /// Shareable invite link + message for the native share sheet.
    var inviteLink: URL {
        URL(string: "https://e-z.rsvp/join/\(inviteCode)") ?? URL(string: "https://e-z.rsvp")!
    }
    var inviteMessage: String {
        "Join my crew \"\(name)\" on e-z.rsvp 🎁 We say yes to mystery experiences before we know what they are — use code \(inviteCode)"
    }

    var readiness: Double {
        guard !members.isEmpty else { return 0 }
        let ready = members.filter(\.isReady).count
        return Double(ready) / Double(members.count)
    }

    init(
        id: String = UUID().uuidString,
        name: String,
        symbol: String = "sparkles",
        ownerID: String,
        inviteCode: String,
        members: [GroupMember] = []
    ) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.ownerID = ownerID
        self.inviteCode = inviteCode
        self.members = members
    }
}
