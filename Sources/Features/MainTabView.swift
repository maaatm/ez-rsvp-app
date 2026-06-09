import SwiftUI

struct MainTabView: View {
    @Environment(SessionStore.self) private var session
    @State private var selection: AppTab = .home

    enum AppTab: Hashable { case home, discover, social, profile }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house.fill", value: AppTab.home) {
                HomeView()
            }
            Tab("Discover", systemImage: "sparkle.magnifyingglass", value: AppTab.discover) {
                DiscoverView()
            }
            Tab("Social", systemImage: "person.2.fill", value: AppTab.social) {
                SocialView()
            }
            Tab("Profile", systemImage: "person.crop.circle.fill", value: AppTab.profile) {
                ProfileView()
            }
        }
        .tint(Theme.ink)
        .task {
            await session.refresh()
            _ = await NotificationService.shared.requestAuthorization()
        }
    }
}
