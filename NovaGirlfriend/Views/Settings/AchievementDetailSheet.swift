import SwiftUI

struct AchievementDetailSheet: View {
  let definition: AchievementDefinition
  let unlockedAt: Date?
  /// The current value of the tracked metric, e.g. completed exchanges.
  let progress: Int
  @Environment(\.dismiss) private var dismiss
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  private var isUnlocked: Bool { unlockedAt != nil }
  private var clampedProgress: Int { isUnlocked ? definition.tier : min(progress, definition.tier) }

  var body: some View {
    ScrollView {
      VStack(spacing: 18) {
        Image(systemName: definition.symbolName)
          .font(.system(size: 34, weight: .semibold))
          .foregroundStyle(isUnlocked ? NovaTheme.primary : NovaTheme.inactiveIcon)
          .frame(width: 84, height: 84)
          .background(NovaTheme.elevatedSurface, in: Circle())
          .overlay(alignment: .bottomTrailing) {
            Image(systemName: isUnlocked ? "checkmark.circle.fill" : "lock.circle.fill")
              .font(.title2)
              .foregroundStyle(isUnlocked ? NovaTheme.primary : NovaTheme.inactiveIcon)
              .background(NovaTheme.surface, in: Circle())
          }
          .accessibilityHidden(true)

        VStack(spacing: 8) {
          Text(definition.kind.title)
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(NovaTheme.textSecondary)
          Text(definition.title)
            .font(.title2.weight(.semibold))
            .accessibilityAddTraits(.isHeader)
          Text(definition.detail)
            .font(.subheadline)
            .foregroundStyle(NovaTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)

        VStack(spacing: 8) {
          ProgressView(value: Double(clampedProgress), total: Double(definition.tier))
            .tint(NovaTheme.primary)
          Group {
            if let unlockedAt {
              Text("Unlocked on \(unlockedAt.formatted(date: .long, time: .omitted))")
            } else {
              Text("\(clampedProgress) of \(definition.tier) \(definition.kind.progressUnit)")
            }
          }
          .font(.caption)
          .foregroundStyle(NovaTheme.textSecondary)
          .accessibilityIdentifier("achievement.progress")
        }
        .accessibilityElement(children: .combine)

        if isUnlocked {
          ShareLink(item: "I unlocked “\(definition.title)” in Nova!") {
            Label("Share", systemImage: "square.and.arrow.up")
              .frame(maxWidth: .infinity)
          }
          .font(NovaTheme.Typography.label)
          .buttonStyle(NovaSecondaryButtonStyle())
          .accessibilityIdentifier("achievement.share")
        }

        Button("Close") { dismiss() }
          .font(.subheadline.weight(.medium))
          .foregroundStyle(NovaTheme.textSecondary)
          .frame(minHeight: 44)
      }
      .padding(24)
      .padding(.top, 8)
    }
    .presentationDetents(dynamicTypeSize.isAccessibilitySize ? [.large] : [.medium, .large])
    .presentationDragIndicator(.visible)
    .presentationBackground(NovaTheme.surface)
    .foregroundStyle(NovaTheme.text)
  }
}

extension AchievementKind {
  fileprivate var progressUnit: String {
    switch self {
    case .exchanges: String(localized: "exchanges")
    case .customCompanions: String(localized: "companions created")
    case .galleryMoments: String(localized: "moments unlocked")
    case .streakDays: String(localized: "days in a row")
    case .boundCompanions: String(localized: "Bound companions")
    }
  }
}
