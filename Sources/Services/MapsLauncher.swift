import Foundation
import MapKit
#if canImport(UIKit)
import UIKit
#endif

/// Opens an event's location in the user's preferred maps app — Apple Maps,
/// Google Maps, or Waze — falling back to the web if the app isn't installed.
/// (Google/Waze URL schemes are declared in Info.plist `LSApplicationQueriesSchemes`.)
enum MapsLauncher {
    @MainActor
    static func open(_ event: MysteryEvent, using app: MapsApp, directions: Bool) {
        Haptics.impact(.light)
        let lat = event.latitude
        let lng = event.longitude

        switch app {
        case .apple:
            let item = MKMapItem(placemark: MKPlacemark(coordinate: event.coordinate))
            item.name = event.venueName
            item.openInMaps(
                launchOptions: directions
                    ? [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    : nil
            )

        case .google:
            let scheme = directions
                ? "comgooglemaps://?daddr=\(lat),\(lng)&directionsmode=driving"
                : "comgooglemaps://?q=\(lat),\(lng)"
            let web = directions
                ? "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lng)"
                : "https://www.google.com/maps/search/?api=1&query=\(lat),\(lng)"
            launch(scheme: scheme, web: web)

        case .waze:
            let nav = directions ? "yes" : "no"
            launch(scheme: "waze://?ll=\(lat),\(lng)&navigate=\(nav)",
                   web: "https://waze.com/ul?ll=\(lat),\(lng)&navigate=\(nav)")
        }
    }

    @MainActor
    private static func launch(scheme: String, web: String) {
        #if canImport(UIKit)
        if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let fallback = URL(string: web) {
            UIApplication.shared.open(fallback)
        }
        #endif
    }
}
