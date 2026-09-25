import SwiftUI

enum AppColors {
  static let background = Color(hex: "0C1218")
  static let container = Color(hex: "1D2124")
  static let elevatedContainer = Color(hex: "24282B")
  static let accentHex = "59EDF4"
  static let accent = Color(hex: accentHex)
  static let gradientStart = Color(hex: "41E3FF")
  static let gradientEnd = Color(hex: "6CF9FF")
  static let primaryText = Color(hex: "F5F7F8")
  static let secondaryText = Color.white.opacity(0.65)
  static let tertiaryText = Color.white.opacity(0.45)
  static let inactiveIcon = Color.white.opacity(0.55)
  static let subtleBorder = Color.white.opacity(0.12)
  static let primaryButtonBorder = Color.white.opacity(0.20)
  static let onAccent = background
  static let onAccentSecondary = background.opacity(0.75)

  static let primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    startPoint: .leading,
    endPoint: .trailing
  )
}
