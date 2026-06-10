import Foundation
import CoreLocation
import Observation

/// A geocoded address suggestion — the iOS analog of the web app's
/// `/api/geocode` results. Carries resolved coordinates so the Discover radius
/// filter can measure distance to each mystery immediately on selection.
struct AddressSuggestion: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Forward-geocoding autocomplete backed by `CLGeocoder` — no API key, on-device,
/// fails soft. Mirrors the web app's address search: debounced lookups, a 3-char
/// threshold, a handful of suggestions, and empty results on error/cancel.
@MainActor
@Observable
final class AddressSearchService {
    var suggestions: [AddressSuggestion] = []
    var isSearching = false

    private let geocoder = CLGeocoder()
    private var task: Task<Void, Never>?

    /// Debounced address lookup. Clears results below the 3-char threshold.
    func search(_ query: String) {
        task?.cancel()
        geocoder.cancelGeocode()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else {
            suggestions = []
            isSearching = false
            return
        }

        task = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(350))
            guard let self, !Task.isCancelled else { return }
            self.isSearching = true

            let placemarks = (try? await self.geocoder.geocodeAddressString(trimmed)) ?? []
            guard !Task.isCancelled else { return }

            var seen = Set<String>()
            self.suggestions = Array(
                placemarks
                    .compactMap(Self.suggestion(from:))
                    .filter { seen.insert($0.label).inserted }
                    .prefix(6)
            )
            self.isSearching = false
        }
    }

    func clear() {
        task?.cancel()
        geocoder.cancelGeocode()
        suggestions = []
        isSearching = false
    }

    /// Builds a readable, deduped label ("Name, City, State") from a placemark.
    private static func suggestion(from placemark: CLPlacemark) -> AddressSuggestion? {
        guard let location = placemark.location else { return nil }
        var parts: [String] = []
        if let name = placemark.name { parts.append(name) }
        if let locality = placemark.locality, !parts.contains(locality) { parts.append(locality) }
        if let admin = placemark.administrativeArea, !parts.contains(admin) { parts.append(admin) }
        let label = parts.isEmpty ? (placemark.name ?? "Selected location") : parts.joined(separator: ", ")
        return AddressSuggestion(
            label: label,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
}
