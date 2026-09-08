import SwiftUI

struct NovaCard<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    content
      .padding(NovaTheme.Spacing.medium)
      .frame(maxWidth: .infinity, alignment: .leading)
      .novaSurface()
  }
}

struct NovaPrimaryButton: View {
  let title: LocalizedStringKey
  let systemImage: String?
  let action: () -> Void

  init(_ title: LocalizedStringKey, systemImage: String? = nil, action: @escaping () -> Void) {
    self.title = title
    self.systemImage = systemImage
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      Label {
        Text(title)
      } icon: {
        if let systemImage {
          Image(systemName: systemImage)
        }
      }
      .font(NovaTheme.Typography.label)
      .foregroundStyle(NovaTheme.background)
      .frame(maxWidth: .infinity)
      .padding(.vertical, NovaTheme.Spacing.small)
    }
    .buttonStyle(NovaPrimaryButtonStyle())
    .controlSize(.large)
    .buttonBorderShape(.capsule)
  }
}

struct NovaPrimaryButtonStyle: PrimitiveButtonStyle {
  @Environment(\.isEnabled) private var isEnabled

  func makeBody(configuration: Configuration) -> some View {
    Button(configuration)
      .buttonStyle(.borderedProminent)
      .buttonBorderShape(.capsule)
      .tint(.clear)
      .foregroundStyle(NovaTheme.background)
      .background(
        NovaTheme.primaryGradient,
        in: Capsule()
      )
      .overlay {
        Capsule()
          .strokeBorder(Color.white.opacity(0.30), lineWidth: 2)
          .allowsHitTesting(false)
      }
      .opacity(isEnabled ? 1 : 0.4)
  }
}

struct NovaSecondaryButtonStyle: PrimitiveButtonStyle {
  @Environment(\.isEnabled) private var isEnabled
  var isSelected = false
  var radius: CGFloat = NovaTheme.Radius.small

  func makeBody(configuration: Configuration) -> some View {
    Button(configuration)
      .buttonStyle(.bordered)
      .buttonBorderShape(.roundedRectangle(radius: radius))
      .tint(.clear)
      .foregroundStyle(
        configuration.role == .destructive
          ? Color.red : (isSelected ? NovaTheme.background : NovaTheme.primary)
      )
      .background(
        isSelected ? NovaTheme.primary : NovaTheme.surface,
        in: RoundedRectangle(cornerRadius: radius)
      )
      .overlay {
        RoundedRectangle(cornerRadius: radius)
          .strokeBorder(
            isSelected ? NovaTheme.primaryButtonBorder : NovaTheme.border, lineWidth: 1
          )
          .allowsHitTesting(false)
      }
      .opacity(isEnabled || isSelected ? 1 : 0.4)
  }
}

private struct NovaActionColorModifier: ViewModifier {
  @Environment(\.isEnabled) private var isEnabled
  let color: Color

  func body(content: Content) -> some View {
    content.foregroundStyle(isEnabled ? color : NovaTheme.inactiveIcon)
  }
}

private struct NovaInputModifier: ViewModifier {
  let cornerRadius: CGFloat
  let focusOverride: Bool?
  @FocusState private var isFocused: Bool

  func body(content: Content) -> some View {
    content
      .focused($isFocused)
      .tint(NovaTheme.primary)
      .foregroundStyle(NovaTheme.text)
      .background(NovaTheme.surface, in: RoundedRectangle(cornerRadius: cornerRadius))
      .overlay {
        RoundedRectangle(cornerRadius: cornerRadius)
          .strokeBorder(
            (focusOverride ?? isFocused) ? NovaTheme.primary : NovaTheme.border, lineWidth: 1
          )
          .allowsHitTesting(false)
      }
  }
}

struct NovaEmptyState: View {
  let title: LocalizedStringKey
  var message: LocalizedStringKey? = nil
  let systemImage: String
  var isEmbedded = false
  var actionTitle: LocalizedStringKey? = nil
  var action: (() -> Void)? = nil

  var body: some View {
    if isEmbedded {
      content
    } else {
      GeometryReader { geometry in
        ScrollView {
          content
            .frame(minHeight: geometry.size.height)
        }
      }
    }
  }

  private var content: some View {
    VStack(spacing: NovaTheme.Spacing.sectionGap) {
      Image(systemName: systemImage)
        .font(.largeTitle)
        .foregroundStyle(NovaTheme.inactiveIcon)
        .accessibilityHidden(true)
      VStack(spacing: NovaTheme.Spacing.titleSubtitle) {
        Text(title)
          .font(NovaTheme.Typography.section)
          .foregroundStyle(NovaTheme.text)
        if let message {
          Text(message)
            .font(.subheadline)
            .foregroundStyle(NovaTheme.textSecondary)
        }
      }
      .accessibilityElement(children: .combine)
      if let actionTitle, let action {
        Button(actionTitle, action: action)
          .buttonStyle(NovaPrimaryButtonStyle())
          .controlSize(.large)
      }
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
    .padding(isEmbedded ? 0 : NovaTheme.Spacing.screenMargin)
  }
}

struct NovaSectionHeader: View {
  let title: LocalizedStringKey
  var subtitle: LocalizedStringKey? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
      Text(title)
        .font(NovaTheme.Typography.section)
        .foregroundStyle(NovaTheme.text)
        .accessibilityAddTraits(.isHeader)
      if let subtitle {
        Text(subtitle)
          .font(.subheadline)
          .foregroundStyle(NovaTheme.textSecondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}

extension View {
  func novaGroupedListSpacing() -> some View {
    self
      .contentMargins(.horizontal, NovaTheme.Spacing.screenMargin, for: .scrollContent)
      .contentMargins(.vertical, NovaTheme.Spacing.screenMargin, for: .scrollContent)
      .listSectionSpacing(NovaTheme.Spacing.sectionGap)
  }

  func novaNavigationTitle(_ title: String) -> some View {
    self
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(title)
            .font(NovaTheme.Typography.headline)
            .foregroundStyle(NovaTheme.text)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("nova.navigationTitle")
        }
      }
  }

  func novaScreen() -> some View {
    self
      .scrollContentBackground(.hidden)
      .background(NovaTheme.background.ignoresSafeArea())
      .presentationBackground(NovaTheme.background)
      .foregroundStyle(NovaTheme.text)
      .tint(NovaTheme.primary)
      .toolbarBackground(NovaTheme.background, for: .navigationBar)
  }

  func novaActionColor(_ color: Color = NovaTheme.primary) -> some View {
    modifier(NovaActionColorModifier(color: color))
  }

  func novaInput(
    cornerRadius: CGFloat = NovaTheme.Radius.small, isFocused: Bool? = nil
  ) -> some View {
    modifier(NovaInputModifier(cornerRadius: cornerRadius, focusOverride: isFocused))
  }

  func novaSurface() -> some View {
    self
      .background(
        NovaTheme.surface,
        in: RoundedRectangle(cornerRadius: NovaTheme.Radius.medium)
      )
      .overlay {
        RoundedRectangle(cornerRadius: NovaTheme.Radius.medium)
          .strokeBorder(NovaTheme.border)
          .allowsHitTesting(false)
      }
  }
}
