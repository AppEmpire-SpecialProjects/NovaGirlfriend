import SwiftUI

struct LegalSheetView: View {
  @Environment(\.dismiss) private var dismiss
  let document: LegalDocument

  var body: some View {
    NavigationStack {
      ScrollView {
        Text(document.body)
          .font(NovaTheme.Typography.body)
          .foregroundStyle(NovaTheme.text)
          .lineSpacing(5)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(NovaTheme.Spacing.medium)
          .novaSurface()
          .padding(NovaTheme.Spacing.screenMargin)
          .textSelection(.enabled)
      }
      .novaScreen()
      .novaNavigationTitle(document.rawValue)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
            .novaActionColor()
        }
      }
    }
  }
}
