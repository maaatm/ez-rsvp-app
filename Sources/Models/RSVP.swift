import Foundation

struct RSVP: Identifiable, Codable, Hashable {
    var id: String
    var eventID: String
    var userID: String
    var groupID: String?
    var status: RSVPStatus
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        eventID: String,
        userID: String,
        groupID: String? = nil,
        status: RSVPStatus = .going,
        createdAt: Date = .now
    ) {
        self.id = id
        self.eventID = eventID
        self.userID = userID
        self.groupID = groupID
        self.status = status
        self.createdAt = createdAt
    }
}
