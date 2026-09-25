import SwiftUI

struct AcquisitionLayout {
  let size: CGSize
  let isPad: Bool

  var isCompact: Bool { size.height < 740 }
  var spacing: CGFloat { isPad ? 8 : (isCompact ? 4 : 6) }
  var maxWidth: CGFloat { isPad ? 500 : 430 }
  var buttonHeight: CGFloat { isPad ? 54 : (isCompact ? 48 : 50) }
  var buttonFontSize: CGFloat { isCompact ? 17 : 18 }
  var footerHeight: CGFloat { isPad ? 40 : (isCompact ? 32 : 36) }
  var footerFontSize: CGFloat { isCompact ? 11 : 12 }
}

struct AcquisitionFooter: View {
  let layout: AcquisitionLayout
  let identifier: String
  let onTerms: () -> Void
  let onRestore: () -> Void
  let onPrivacy: () -> Void

  var body: some View {
    HStack(spacing: 0) {
      link("Terms of Use", name: "terms", action: onTerms)
      divider
      link("Restore", name: "restore", action: onRestore)
      divider
      link("Privacy Policy", name: "privacy", action: onPrivacy)
    }
    .frame(height: layout.footerHeight)
  }

  private func link(_ title: String, name: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: layout.footerFontSize))
        .foregroundStyle(.white.opacity(0.5))
        .padding(.horizontal, 8)
        .frame(height: layout.footerHeight)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier("\(identifier).\(name)")
  }

  private var divider: some View {
    Rectangle()
      .fill(.white.opacity(0.2))
      .frame(width: 0.5, height: 18)
  }
}
