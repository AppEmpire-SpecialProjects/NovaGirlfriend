import SwiftUI

struct ScenarioCard: View {
  let scenario: Scenario

  var body: some View {
    HStack(spacing: NovaTheme.Spacing.medium) {
      ZStack {
        RoundedRectangle(cornerRadius: NovaTheme.Radius.medium)
          .fill(NovaTheme.surface)
        Image(systemName: scenario.symbolName)
          .font(.title2)
          .foregroundStyle(NovaTheme.primary)
          .accessibilityHidden(true)
      }
      .frame(width: 68, height: 68)

      VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
        Text(scenario.title)
          .font(NovaTheme.Typography.headline)
        Text(scenario.summary)
          .font(.subheadline)
          .foregroundStyle(NovaTheme.textSecondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      Spacer(minLength: 4)
      Image(systemName: "chevron.right")
        .font(.caption.weight(.semibold))
        .foregroundStyle(NovaTheme.primary)
    }
    .foregroundStyle(NovaTheme.text)
    .padding(NovaTheme.Spacing.medium)
    .novaSurface()
    .accessibilityElement(children: .combine)
    .accessibilityHint("Opens scenario details")
  }
}
