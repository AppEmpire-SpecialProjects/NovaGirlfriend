import SwiftUI

/// Colors from the onboarding design, independent of the main app theme.
enum OnboardingPalette {
  static let background = Color(hex: "17191B")
  static let dot = Color(hex: "59EDF4")
  static let onGradient = Color(hex: "17191B")
  static let pillFill = Color(hex: "272A2D")
  static let pillBorder = Color(hex: "3B3C3C")
  static let pillInfo = Color(hex: "C7C7CC")
  static let gradient = LinearGradient(
    colors: [Color(hex: "6CF9FF"), Color(hex: "41E3FF")],
    startPoint: .top,
    endPoint: .bottom
  )
}
