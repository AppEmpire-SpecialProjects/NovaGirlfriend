import SwiftData
import SwiftUI

@main
struct NovaGirlfriendApp: App {
  @State private var modelContainer: ModelContainer?
  @State private var storageError: String?

  init() {
    NovaTheme.configureNavigationAppearance()
    #if DEBUG
      if ProcessInfo.processInfo.arguments.contains("--uitest-reset-onboarding") {
        UserDefaults.standard.set(false, forKey: "preferences.hasCompletedOnboarding")
      }
    #endif
    do {
      _modelContainer = State(initialValue: try PersistenceController.makeContainer())
    } catch {
      _storageError = State(initialValue: error.localizedDescription)
    }
  }

  var body: some Scene {
    WindowGroup {
      if let modelContainer {
        ContentView()
          .modelContainer(modelContainer)
      } else {
        NovaEmptyState(
          title: "Local storage unavailable",
          message: LocalizedStringKey(
            storageError
              ?? "The local data store could not be opened. Your existing data has not been deleted."
          ),
          systemImage: "externaldrive.badge.exclamationmark", actionTitle: "Retry",
          action: {
            do {
              modelContainer = try PersistenceController.makeContainer()
              storageError = nil
            } catch {
              storageError = error.localizedDescription
            }
          }
        )
        .foregroundStyle(NovaTheme.text)
        .tint(NovaTheme.primary)
        .background(NovaTheme.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
      }
    }
  }
}
