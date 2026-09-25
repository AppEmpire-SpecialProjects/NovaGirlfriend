import SwiftData
import SwiftUI

struct AchievementsView: View {
  @Query(sort: \AchievementRecord.unlockedAt, order: .reverse) private var records: [
    AchievementRecord
  ]
  @Query private var streaks: [UserStreakRecord]
  @Query private var messages: [MessageRecord]
  @Query private var characters: [CharacterRecord]
  @Query private var galleryItems: [GalleryItemRecord]
  @Query private var affinities: [AffinityRecord]
  @State private var selected: AchievementDefinition?

  private var unlockedIDs: Set<String> { Set(records.map(\.definitionID)) }
  private var streak: UserStreakRecord? { streaks.first }

  private func unlockedAt(_ definition: AchievementDefinition) -> Date? {
    records.first { $0.definitionID == definition.id }?.unlockedAt
  }

  /// Current value of the metric each achievement kind tracks.
  private func progress(for kind: AchievementKind) -> Int {
    switch kind {
    case .exchanges:
      messages.filter {
        $0.roleRawValue == MessageRole.user.rawValue
          && $0.deliveryStateRawValue == MessageDeliveryState.sent.rawValue
      }.count
    case .customCompanions:
      characters.filter { $0.originRawValue == CharacterOrigin.custom.rawValue }.count
    case .galleryMoments:
      galleryItems.filter(\.isUnlocked).count
    case .streakDays:
      streak?.currentStreak ?? 0
    case .boundCompanions:
      affinities.filter { AffinityStage.stage(forPoints: $0.points) >= .bound }.count
    }
  }

  var body: some View {
    List {
      if let streak {
        Section {
          HStack(spacing: NovaTheme.Spacing.medium) {
            Image(systemName: "flame.fill")
              .font(.title2)
              .foregroundStyle(NovaTheme.primary)
              .frame(width: 40, height: 40)
              .background(NovaTheme.elevatedSurface, in: Circle())
              .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
              Text("\(streak.currentStreak)-day streak")
                .font(NovaTheme.Typography.headline)
                .foregroundStyle(NovaTheme.text)
              Text("Longest: \(streak.longestStreak) days")
                .font(NovaTheme.Typography.caption)
                .foregroundStyle(NovaTheme.textSecondary)
            }
            Spacer()
          }
        }
        .listRowBackground(NovaTheme.surface)
        .listRowSeparatorTint(NovaTheme.border)
      }

      Section {
        ForEach(AchievementCatalog.all) { definition in
          Button {
            selected = definition
          } label: {
            AchievementRow(definition: definition, unlockedAt: unlockedAt(definition))
          }
          .buttonStyle(.plain)
          .accessibilityIdentifier("achievement.\(definition.id)")
        }
      } header: {
        Text("\(unlockedIDs.count) of \(AchievementCatalog.all.count) unlocked")
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
    .novaNavigationTitle("Achievements")
    .toolbar(.hidden, for: .tabBar)
    .sheet(item: $selected) { definition in
      AchievementDetailSheet(
        definition: definition, unlockedAt: unlockedAt(definition),
        progress: progress(for: definition.kind))
    }
  }
}

private struct AchievementRow: View {
  let definition: AchievementDefinition
  let unlockedAt: Date?
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  private var isUnlocked: Bool { unlockedAt != nil }

  var body: some View {
    HStack(spacing: NovaTheme.Spacing.medium) {
      Image(systemName: definition.symbolName)
        .foregroundStyle(isUnlocked ? NovaTheme.primary : NovaTheme.inactiveIcon)
        .frame(width: 40, height: 40)
        .background(NovaTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: NovaTheme.Radius.small))
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 2) {
        Text(definition.title)
          .font(NovaTheme.Typography.body)
          .foregroundStyle(NovaTheme.text)
        Text(definition.subtitle)
          .font(NovaTheme.Typography.caption)
          .foregroundStyle(NovaTheme.textSecondary)
      }
      Spacer()
      if isUnlocked {
        VStack(alignment: .trailing, spacing: 2) {
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(NovaTheme.primary)
            .accessibilityLabel("Unlocked")
          Text(unlockedAt!, format: .dateTime.month().day())
            .font(NovaTheme.Typography.caption2)
            .foregroundStyle(NovaTheme.textTertiary)
        }
      } else {
        Image(systemName: "lock.fill")
          .foregroundStyle(NovaTheme.inactiveIcon)
          .accessibilityHidden(true)
      }
      Image(systemName: "chevron.right")
        .font(.caption.weight(.semibold))
        .foregroundStyle(NovaTheme.textTertiary)
        .accessibilityHidden(true)
    }
    .padding(.vertical, NovaTheme.Spacing.extraSmall)
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
    .accessibilityHint(isUnlocked ? "Unlocked" : "Locked")
  }
}
