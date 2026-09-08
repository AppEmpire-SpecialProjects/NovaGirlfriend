import SwiftUI

struct ChatScenarioSelectionView: View {
  @ObservedObject var model: ChatViewModel
  @Environment(\.dismiss) private var dismiss
  private let scenarios = ProductContentRepository().scenarios

  var body: some View {
    NavigationStack {
      List {
        Section {
          option(nil)
          ForEach(scenarios) { scenario in
            option(scenario)
          }
        } footer: {
          Text("Changes the setting for future replies. Your messages stay in this conversation.")
        }
        if let error = model.error {
          Text(error)
            .font(.subheadline)
            .foregroundStyle(.red)
            .listRowBackground(NovaTheme.surface)
        }
      }
      .novaGroupedListSpacing()
      .novaScreen()
      .novaNavigationTitle("Choose Scenario")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
            .novaActionColor()
        }
      }
    }
  }

  private func option(_ scenario: Scenario?) -> some View {
    let selected = model.scenario?.id == scenario?.id
    return Button {
      if model.selectScenario(scenario) { dismiss() }
    } label: {
      HStack(spacing: NovaTheme.Spacing.medium) {
        Image(systemName: scenario?.symbolName ?? "bubble.left.and.bubble.right")
          .foregroundStyle(NovaTheme.primary)
          .frame(width: 28)
          .accessibilityHidden(true)
        VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
          Text(scenario?.title ?? "No Scenario")
            .font(NovaTheme.Typography.headline)
            .foregroundStyle(NovaTheme.text)
          if let scenario {
            Text(scenario.summary)
              .font(.subheadline)
              .foregroundStyle(NovaTheme.textSecondary)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
        Spacer()
        if selected {
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(NovaTheme.primary)
            .accessibilityHidden(true)
        }
      }
      .padding(.vertical, NovaTheme.Spacing.extraSmall)
    }
    .disabled(model.isThinking || model.conversation == nil)
    .listRowBackground(NovaTheme.surface)
    .listRowSeparatorTint(NovaTheme.border)
    .accessibilityIdentifier("chat.scenario.\(scenario?.id ?? "none")")
    .accessibilityValue(selected ? "Selected" : "")
    .accessibilityAddTraits(selected ? .isSelected : [])
  }
}
