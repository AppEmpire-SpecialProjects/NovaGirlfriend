import SwiftUI

/// Compact stage chip with progress toward the next affinity threshold.
struct AffinityBadge: View {
  let stage: AffinityStage
  let points: Int

  private var progress: Double {
    AffinityStage.progress(from: stage, points: points)
  }

  var body: some View {
    VStack(spacing: 6) {
      HStack(spacing: 6) {
        Image(systemName: stage.symbolName)
          .foregroundStyle(NovaTheme.primary)
        Text("Bond: \(stage.title)")
          .font(NovaTheme.Typography.caption)
          .foregroundStyle(NovaTheme.text)
        if let next = stage.next {
          Text("\(points)/\(next.threshold)")
            .font(NovaTheme.Typography.caption)
            .foregroundStyle(NovaTheme.textTertiary)
            .monospacedDigit()
        }
      }
      if let next = stage.next {
        GeometryReader { geometry in
          ZStack(alignment: .leading) {
            Capsule().fill(NovaTheme.border)
            Capsule()
              .fill(NovaTheme.primary)
              .frame(width: geometry.size.width * progress)
          }
        }
        .frame(height: 4)
        .accessibilityHidden(true)
      } else {
        Text(stage.detail)
          .font(NovaTheme.Typography.caption)
          .foregroundStyle(NovaTheme.textSecondary)
      }
    }
    .padding(.horizontal, NovaTheme.Spacing.medium)
    .padding(.vertical, 6)
    .background(NovaTheme.elevatedSurface, in: Capsule())
    .accessibilityElement(children: .combine)
    .accessibilityIdentifier("chat.affinityBadge")
  }
}
