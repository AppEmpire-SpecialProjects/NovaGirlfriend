import SwiftUI

struct ExperienceSettingsView: View {
  @AppStorage("preferences.hapticsEnabled") private var hapticsEnabled = true
  @AppStorage("preferences.reduceMotion") private var reduceMotion = false

  var body: some View {
    Form {
      Section {
        Toggle("Haptics", isOn: $hapticsEnabled)
        Toggle("Reduce motion", isOn: $reduceMotion)
      } header: {
        Text("Feedback")
          .font(NovaTheme.Typography.headline)
          .textCase(nil)
          .foregroundStyle(NovaTheme.textSecondary)
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)

      Section {
        Label(
          "Permissions are requested only when you use a related feature.",
          systemImage: "lock.shield"
        )
        Text(
          "Avatar photos remain in the app’s local private storage unless you explicitly share an export."
        )
      } header: {
        Text("Privacy")
          .font(NovaTheme.Typography.headline)
          .textCase(nil)
      }
      .foregroundStyle(NovaTheme.textSecondary)
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
    }
    .novaGroupedListSpacing()
    .novaScreen()
    .novaNavigationTitle("Experience")
    .toolbar(.hidden, for: .tabBar)
  }
}
