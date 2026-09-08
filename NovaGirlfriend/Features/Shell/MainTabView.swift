import SwiftUI

struct MainTabView: View {
  @State private var selection: AppTab = .discover
  @State private var conversationsPath = NavigationPath()

  var body: some View {
    TabView(selection: $selection) {
      NavigationStack {
        DiscoverView()
      }
      .toolbarBackground(NovaTheme.surface, for: .tabBar)
      .toolbarBackground(.visible, for: .tabBar)
      .tabItem { Label(AppTab.discover.title, systemImage: AppTab.discover.systemImage) }
      .tag(AppTab.discover)

      NavigationStack(path: $conversationsPath) {
        ConversationsView()
          .navigationDestination(for: ChatLaunchContext.self) { context in
            ChatView(character: context.character, scenario: context.scenario, startNew: true)
          }
      }
      .toolbarBackground(NovaTheme.surface, for: .tabBar)
      .toolbarBackground(.visible, for: .tabBar)
      .tabItem { Label(AppTab.conversations.title, systemImage: AppTab.conversations.systemImage) }
      .tag(AppTab.conversations)

      NavigationStack {
        GalleryView()
      }
      .toolbarBackground(NovaTheme.surface, for: .tabBar)
      .toolbarBackground(.visible, for: .tabBar)
      .tabItem { Label(AppTab.gallery.title, systemImage: AppTab.gallery.systemImage) }
      .tag(AppTab.gallery)

      NavigationStack {
        SettingsView()
      }
      .toolbarBackground(NovaTheme.surface, for: .tabBar)
      .toolbarBackground(.visible, for: .tabBar)
      .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage) }
      .tag(AppTab.settings)
    }
    .tint(NovaTheme.primary)
    .environment(
      \.launchChat,
      ChatLaunchAction { context in
        selection = .conversations
        conversationsPath.append(context)
      })
  }
}
