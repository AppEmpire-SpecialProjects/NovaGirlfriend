import SwiftUI

struct CelebrationToast: View {
  let title: String
  let subtitle: String
  let symbolName: String

  var body: some View {
    HStack(spacing: NovaTheme.Spacing.medium) {
      Image(systemName: symbolName)
        .font(.title2)
        .foregroundStyle(NovaTheme.primary)
        .frame(width: 40, height: 40)
        .background(NovaTheme.elevatedSurface, in: Circle())
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(NovaTheme.Typography.headline)
          .foregroundStyle(NovaTheme.text)
        Text(subtitle)
          .font(NovaTheme.Typography.caption)
          .foregroundStyle(NovaTheme.textSecondary)
          .lineLimit(2)
      }
      Spacer(minLength: 0)
    }
    .padding(NovaTheme.Spacing.medium)
    .background(NovaTheme.surface, in: RoundedRectangle(cornerRadius: NovaTheme.Radius.medium))
    .overlay {
      RoundedRectangle(cornerRadius: NovaTheme.Radius.medium)
        .strokeBorder(NovaTheme.border)
        .allowsHitTesting(false)
    }
    .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
    .padding(.horizontal, NovaTheme.Spacing.screenMargin)
    .accessibilityElement(children: .combine)
    .accessibilityIdentifier("chat.celebrationToast")
  }
}
