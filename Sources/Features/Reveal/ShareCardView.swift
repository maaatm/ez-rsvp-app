import SwiftUI
import CoreImage.CIFilterBuiltins
#if canImport(UIKit)
import UIKit
#endif

struct ShareCardView: View {
    @Environment(\.dismiss) private var dismiss
    let event: MysteryEvent
    var groupCount: Int = 5

    @State private var rendered: Image?

    private var shareURL: String { "https://e-z.rsvp/reveal/\(event.id)" }

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()
                ScrollView {
                    VStack(spacing: Theme.Space.lg) {
                        card
                            .frame(maxWidth: 340)

                        VStack(spacing: 12) {
                            if let rendered {
                                ShareLink(
                                    item: rendered,
                                    preview: SharePreview("My e-z.rsvp reveal", image: rendered)
                                ) {
                                    Label("Share to…", systemImage: "square.and.arrow.up")
                                }
                                .buttonStyle(.primary)
                            }
                            Text("Post to Messages, Instagram, Snapchat, TikTok — or save the image.")
                                .font(.caption).foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, Theme.Space.lg)
                    }
                    .padding(Theme.Space.lg)
                }
            }
            .navigationTitle("Flex your mystery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .task { renderCard() }
        }
        .presentationDragIndicator(.visible)
    }

    // The shareable card
    private var card: some View {
        VStack(spacing: 16) {
            HStack(spacing: 5) {
                Image(systemName: "sparkles")
                Text("e-z").fontWeight(.bold) + Text(".rsvp").fontWeight(.bold).foregroundColor(Color(white: 0.95))
            }
            .font(.subheadline)
            .foregroundStyle(.white)

            Text("I trusted e-z.rsvp and got")
                .font(.subheadline).foregroundStyle(.white.opacity(0.85))

            Image(systemName: event.imageSymbol)
                .font(.system(size: 70)).foregroundStyle(.white)
                .padding(.vertical, 4)

            Text(event.title)
                .font(.system(.title, design: .rounded).weight(.heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                pill("mappin", event.generalArea)
                pill("clock", event.eventTime.formatted(style: .time))
            }
            pill("person.2.fill", "\(groupCount) friends")

            Text("“Said yes first. Found out later.”")
                .font(.callout).italic().foregroundStyle(.white.opacity(0.9))
                .padding(.top, 4)

            // QR
            HStack(spacing: 12) {
                if let qr = qrImage(from: shareURL) {
                    qr.resizable().interpolation(.none)
                        .frame(width: 60, height: 60)
                        .padding(6).background(.white, in: RoundedRectangle(cornerRadius: 8))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Join the mystery").font(.caption.weight(.bold)).foregroundStyle(.white)
                    Text("scan to RSVP →").font(.caption2).foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(10)
            .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(28)
        .background(
            LinearGradient(colors: [Color(red: 0.106, green: 0.110, blue: 0.137),  // #1B1C23 deep charcoal
                                    Color(red: 0.231, green: 0.180, blue: 0.275)], // #3B2E46 charcoal-purple
                           startPoint: .top, endPoint: .bottom)
        )
        .overlay(alignment: .topTrailing) {
            Circle().fill(Theme.fuchsia.opacity(0.4)).frame(width: 160, height: 160).blur(radius: 60)
                .offset(x: 40, y: -40)
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
    }

    private func pill(_ symbol: String, _ text: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.caption.weight(.medium)).foregroundStyle(.white)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(.white.opacity(0.15), in: Capsule())
    }

    // MARK: Rendering & QR

    @MainActor private func renderCard() {
        let renderer = ImageRenderer(content: card.frame(width: 340))
        renderer.scale = 3
        #if canImport(UIKit)
        if let ui = renderer.uiImage { rendered = Image(uiImage: ui) }
        #endif
    }

    private func qrImage(from string: String) -> Image? {
        #if canImport(UIKit)
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 8, y: 8)),
              let cg = context.createCGImage(output, from: output.extent) else { return nil }
        return Image(uiImage: UIImage(cgImage: cg))
        #else
        return nil
        #endif
    }
}
