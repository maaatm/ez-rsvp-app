import Foundation
import SwiftData

/// SwiftData-backed local cache so the feed renders instantly on cold launch
/// and survives offline. Stores each event as a JSON blob keyed by id.
@Model
final class CachedEvent {
    @Attribute(.unique) var id: String
    var payload: Data
    var cachedAt: Date

    init(id: String, payload: Data, cachedAt: Date = .now) {
        self.id = id
        self.payload = payload
        self.cachedAt = cachedAt
    }
}

/// Self-contained store (its own ModelContainer) so it can be used from
/// `SessionStore` without depending on the SwiftUI environment.
@MainActor
final class EventCache {
    static let shared = EventCache()

    private let container: ModelContainer?

    private init() {
        container = try? ModelContainer(
            for: CachedEvent.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: false)
        )
    }

    func save(_ events: [MysteryEvent]) {
        guard let context = container?.mainContext else { return }
        let encoder = JSONEncoder()
        for event in events {
            guard let data = try? encoder.encode(event) else { continue }
            context.insert(CachedEvent(id: event.id, payload: data))
        }
        try? context.save()
    }

    func load() -> [MysteryEvent] {
        guard let context = container?.mainContext else { return [] }
        let descriptor = FetchDescriptor<CachedEvent>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )
        let rows = (try? context.fetch(descriptor)) ?? []
        let decoder = JSONDecoder()
        return rows.compactMap { try? decoder.decode(MysteryEvent.self, from: $0.payload) }
    }
}
