import SwiftUI

struct AboutView: View {
  private var version: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
      ?? "Unavailable"
  }

  private var build: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unavailable"
  }

  var body: some View {
    Form {
      Section {
        VStack(spacing: NovaTheme.Spacing.medium) {
          Image(systemName: "sparkles")
            .font(.largeTitle)
            .foregroundStyle(NovaTheme.primary)
            .padding(NovaTheme.Spacing.large)
            .background(
              NovaTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: NovaTheme.Radius.large)
            )
            .accessibilityHidden(true)
          Text("Nova").font(NovaTheme.Typography.display)
          Text("A private, personal companion experience.")
            .foregroundStyle(NovaTheme.textSecondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, NovaTheme.Spacing.medium)
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
      Section {
        LabeledContent("Version") {
          Text(version).foregroundStyle(NovaTheme.textSecondary)
        }
        LabeledContent("Build") {
          Text(build).foregroundStyle(NovaTheme.textSecondary)
        }
      } header: {
        Text("Build Information")
          .font(NovaTheme.Typography.headline)
          .textCase(nil)
          .foregroundStyle(NovaTheme.textSecondary)
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
    }
    .novaGroupedListSpacing()
    .novaScreen()
    .novaNavigationTitle("About")
    .toolbar(.hidden, for: .tabBar)
  }
}
