import SwiftUI
import MapKit

/// Map that starts heavily blurred + zoomed out, then smoothly zooms into the
/// venue and drops a pin. The cornerstone of the reveal's "where am I going?!"
/// moment. Set `zoomIn` to true to trigger the cinematic focus.
struct BlurredMapView: View {
    let event: MysteryEvent
    var zoomIn: Bool

    @State private var position: MapCameraPosition
    @State private var pinDropped = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(event: MysteryEvent, zoomIn: Bool) {
        self.event = event
        self.zoomIn = zoomIn
        // Start wide (city-scale).
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: event.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
        )))
    }

    var body: some View {
        // Gate the Metal-backed Map on a measured, non-zero size. Inside a
        // ScrollView the map otherwise gets built during transient 0-height
        // layout passes, which makes MapKit allocate invalid drawables — the
        // "CAMetalLayer ignoring invalid setDrawableSize 0×0" / "1206x0 image
        // slot" churn. Until the container has a real size we show a cheap,
        // non-Metal placeholder (imperceptible: it only spans one layout pass).
        GeometryReader { proxy in
            if proxy.size.width > 1, proxy.size.height > 1 {
                mapContent
                    .frame(width: proxy.size.width, height: proxy.size.height)
            } else {
                Theme.surfaceSunken
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        .onChange(of: zoomIn) { _, newValue in
            guard newValue else { return }
            focusIn()
        }
        .onAppear { if zoomIn { focusIn() } }
    }

    private var mapContent: some View {
        Map(position: $position, interactionModes: zoomIn ? .all : []) {
            if pinDropped {
                Annotation(event.venueName, coordinate: event.coordinate) {
                    venuePin
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .blur(radius: zoomIn ? 0 : 16)
        .overlay {
            if !zoomIn {
                ZStack {
                    Color.black.opacity(0.25)
                    Label("Locating your mystery destination…", systemImage: "mappin.and.ellipse")
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
        }
    }

    private var venuePin: some View {
        ZStack {
            Circle().fill(Theme.fuchsia.opacity(0.3)).frame(width: 56, height: 56).blur(radius: 8)
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 38))
                .foregroundStyle(.white, Theme.fuchsia)
                .symbolEffect(.bounce, value: pinDropped)
        }
        .scaleEffect(pinDropped ? 1 : 0.1)
        .animation(.spring(response: 0.5, dampingFraction: 0.55), value: pinDropped)
    }

    private func focusIn() {
        let duration = reduceMotion ? 0.1 : 1.8
        withAnimation(.easeInOut(duration: duration)) {
            position = .region(MKCoordinateRegion(
                center: event.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
            ))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.1 : 0.7)) {
            pinDropped = true
        }
    }
}
