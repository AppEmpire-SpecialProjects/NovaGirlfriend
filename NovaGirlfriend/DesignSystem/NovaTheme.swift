import SwiftUI
import UIKit

enum NovaTheme {
  enum Spacing {
    static let screenMargin: CGFloat = 16
    static let cardGap: CGFloat = 12
    static let sectionGap: CGFloat = 16
    static let titleSubtitle: CGFloat = 2

    static let extraSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
  }

  enum Radius {
    static let small: CGFloat = 10
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
  }

  enum Typography {
    static let display = Font.system(.largeTitle, design: .rounded, weight: .semibold)
    static let title = Font.system(.title, design: .rounded, weight: .semibold)
    static let section = Font.system(.title2, design: .rounded, weight: .semibold)
    static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let body = Font.system(.body, design: .default)
    static let label = Font.system(.body, design: .default, weight: .semibold)
    static let caption = Font.system(.caption, design: .default)
    static let caption2 = Font.system(.caption2, design: .default)
  }

  static let background = AppColors.background
  static let surface = AppColors.container
  static let elevatedSurface = AppColors.elevatedContainer
  static let primary = AppColors.accent
  static let secondary = AppColors.accent
  static let text = AppColors.primaryText
  static let textSecondary = AppColors.secondaryText
  static let textTertiary = AppColors.tertiaryText
  static let inactiveIcon = AppColors.inactiveIcon
  static let border = AppColors.subtleBorder
  static let primaryButtonBorder = AppColors.primaryButtonBorder
  static let primaryGradient = AppColors.primaryGradient
  static let outgoingMessage = AppColors.gradientStart
  static let outgoingMessageText = AppColors.onAccent
  static let outgoingMessageSecondaryText = AppColors.onAccentSecondary

  @MainActor private static let searchFieldTheme = SearchFieldTheme()

  @MainActor
  static func configureNavigationAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(background)
    appearance.shadowColor = .clear
    appearance.titleTextAttributes = [
      .font: roundedFont(for: .headline),
      .foregroundColor: UIColor(text),
    ]
    appearance.largeTitleTextAttributes = [
      .font: roundedFont(for: .largeTitle),
      .foregroundColor: UIColor(text),
    ]
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().tintColor = UIColor(primary)

    let tabAppearance = UITabBarAppearance()
    tabAppearance.configureWithOpaqueBackground()
    tabAppearance.backgroundColor = UIColor(surface)
    tabAppearance.shadowColor = UIColor(border)
    for item in [
      tabAppearance.stackedLayoutAppearance,
      tabAppearance.inlineLayoutAppearance,
      tabAppearance.compactInlineLayoutAppearance,
    ] {
      item.normal.iconColor = UIColor(inactiveIcon)
      item.normal.titleTextAttributes = [.foregroundColor: UIColor(inactiveIcon)]
      item.selected.iconColor = UIColor(primary)
      item.selected.titleTextAttributes = [.foregroundColor: UIColor(primary)]
    }
    UITabBar.appearance().standardAppearance = tabAppearance
    UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    UITabBar.appearance().tintColor = UIColor(primary)
    UITabBar.appearance().unselectedItemTintColor = UIColor(inactiveIcon)

    UISegmentedControl.appearance().backgroundColor = UIColor(surface)
    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(primary)
    UISegmentedControl.appearance().setTitleTextAttributes(
      [.foregroundColor: UIColor(text)], for: .normal)
    UISegmentedControl.appearance().setTitleTextAttributes(
      [.foregroundColor: UIColor(background)], for: .selected)
    UISwitch.appearance().onTintColor = UIColor(primary)
    UISearchBar.appearance().tintColor = UIColor(primary)
    UISearchTextField.appearance().backgroundColor = .clear
    UISearchTextField.appearance().textColor = UIColor(text)
    UISearchTextField.appearance().tintColor = UIColor(primary)
    _ = searchFieldTheme
    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(primary)
    UIPageControl.appearance().pageIndicatorTintColor = UIColor(textTertiary)
  }

  private static func roundedFont(for style: UIFont.TextStyle) -> UIFont {
    let size = UIFont.preferredFont(forTextStyle: style).pointSize
    let descriptor = UIFont.systemFont(ofSize: size, weight: .semibold).fontDescriptor
    return UIFont(descriptor: descriptor.withDesign(.rounded) ?? descriptor, size: size)
  }
}

@MainActor
private final class SearchFieldTheme: NSObject {
  override init() {
    super.init()
    let radius = NovaTheme.Radius.small
    let size = CGSize(width: radius * 2 + 2, height: 36)
    let image = UIGraphicsImageRenderer(size: size).image { _ in
      let path = UIBezierPath(
        roundedRect: CGRect(origin: .zero, size: size).insetBy(dx: 0.5, dy: 0.5),
        cornerRadius: radius
      )
      UIColor(NovaTheme.surface).setFill()
      path.fill()
      UIColor(NovaTheme.border).setStroke()
      path.lineWidth = 1
      path.stroke()
    }
    UISearchBar.appearance().setSearchFieldBackgroundImage(
      image.resizableImage(
        withCapInsets: UIEdgeInsets(top: radius, left: radius, bottom: radius, right: radius)
      ),
      for: .normal
    )
    for name in [
      UITextField.textDidBeginEditingNotification, UITextField.textDidEndEditingNotification,
    ] {
      NotificationCenter.default.addObserver(
        self, selector: #selector(editingChanged(_:)), name: name, object: nil
      )
    }
  }

  @objc private func editingChanged(_ notification: Notification) {
    guard let field = notification.object as? UISearchTextField else { return }
    field.layer.cornerRadius = NovaTheme.Radius.small
    field.layer.borderWidth = 1
    field.layer.borderColor =
      notification.name == UITextField.textDidBeginEditingNotification
      ? UIColor(NovaTheme.primary).cgColor : UIColor.clear.cgColor
  }
}

extension Color {
  init(hex: String) {
    let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    let value = UInt64(cleaned, radix: 16) ?? 0
    let red = Double((value >> 16) & 0xFF) / 255
    let green = Double((value >> 8) & 0xFF) / 255
    let blue = Double(value & 0xFF) / 255
    self.init(red: red, green: green, blue: blue)
  }
}
