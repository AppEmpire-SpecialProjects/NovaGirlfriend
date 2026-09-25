import SwiftData
import SwiftUI

/// Shows the facts companions have remembered about the user and lets the
/// user prune anything they would rather not keep.
struct MemoryView: View {
  @Query(sort: \MemoryFactRecord.createdAt) private var facts: [MemoryFactRecord]
  @Environment(\.modelContext) private var context
  @State private var pendingDeletion: MemoryFactRecord?

  var body: some View {
    List {
      Section {
        if facts.isEmpty {
          VStack(spacing: NovaTheme.Spacing.small) {
            Image(systemName: "brain")
              .font(.largeTitle)
              .foregroundStyle(NovaTheme.inactiveIcon)
            Text("Nothing remembered yet")
              .font(NovaTheme.Typography.section)
              .foregroundStyle(NovaTheme.text)
            Text(
              "As you chat, your companions quietly remember the details you share about yourself."
            )
            .font(NovaTheme.Typography.caption)
            .foregroundStyle(NovaTheme.textSecondary)
            .multilineTextAlignment(.center)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, NovaTheme.Spacing.sectionGap)
        } else {
          ForEach(facts) { fact in
            HStack(alignment: .top, spacing: NovaTheme.Spacing.medium) {
              Image(systemName: "sparkle")
                .foregroundStyle(NovaTheme.primary)
                .padding(.top, 2)
                .accessibilityHidden(true)
              Text(fact.text)
                .font(NovaTheme.Typography.body)
                .foregroundStyle(NovaTheme.text)
              Spacer(minLength: 0)
            }
            .padding(.vertical, NovaTheme.Spacing.extraSmall)
            .swipeActions {
              Button(role: .destructive) {
                pendingDeletion = fact
              } label: {
                Label("Forget", systemImage: "brain.filled.head.profile")
              }
            }
          }
        }
      } header: {
        Text("Remembered about you")
          .font(NovaTheme.Typography.headline)
          .textCase(nil)
          .foregroundStyle(NovaTheme.textSecondary)
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
    }
    .listStyle(.insetGrouped)
    .novaGroupedListSpacing()
    .novaScreen()
    .novaNavigationTitle("Memory")
    .toolbar(.hidden, for: .tabBar)
    .confirmationDialog(
      "Let your companions forget this?",
      isPresented: Binding(
        get: { pendingDeletion != nil },
        set: { if !$0 { pendingDeletion = nil } }),
      titleVisibility: .visible
    ) {
      Button("Forget", role: .destructive) {
        if let fact = pendingDeletion {
          context.delete(fact)
          try? context.save()
        }
        pendingDeletion = nil
      }
      Button("Cancel", role: .cancel) { pendingDeletion = nil }
    }
  }
}
