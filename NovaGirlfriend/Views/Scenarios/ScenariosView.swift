import SwiftUI

struct ScenariosView: View {
  let scenarios: [Scenario]
  let characters: [CharacterProfile]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: NovaTheme.Spacing.sectionGap) {
        Text(
          "Choose a setting to shape the next conversation. You will confirm a character before anything begins."
        )
        .font(NovaTheme.Typography.body)
        .foregroundStyle(NovaTheme.textSecondary)
        .fixedSize(horizontal: false, vertical: true)

        LazyVStack(spacing: NovaTheme.Spacing.cardGap) {
          ForEach(scenarios) { scenario in
            NavigationLink {
              ScenarioDetailView(scenario: scenario, characters: characters)
            } label: {
              ScenarioCard(scenario: scenario)
            }
            .buttonStyle(.plain)
          }
        }
      }
      .padding(NovaTheme.Spacing.screenMargin)
    }
    .novaScreen()
    .toolbar(.hidden, for: .tabBar)
    .novaNavigationTitle("Scenarios")
  }
}
