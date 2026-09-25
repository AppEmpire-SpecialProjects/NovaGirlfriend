import SwiftUI

struct AIConnectionView: View {
  @State private var token = ""
  @State private var status: String?

  var body: some View {
    Form {
      Section {
        Text(
          "Your app provider must configure an HTTPS NovaAIBaseURL endpoint implementing POST /v1/completions. No AI replies are simulated when the service is unavailable."
        )
        Text(
          "Messages, character personality, and scenario are sent to this service only when you send text."
        )
        .foregroundStyle(NovaTheme.textSecondary)
      } header: {
        Text("Service")
          .font(NovaTheme.Typography.headline)
          .textCase(nil)
          .foregroundStyle(NovaTheme.textSecondary)
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
      Section {
        SecureField(
          "New access token", text: $token,
          prompt: Text("New access token").foregroundStyle(NovaTheme.textTertiary)
        )
        .textContentType(.password).autocorrectionDisabled().textInputAutocapitalization(.never)
        .novaInput()
        Button("Save to Keychain") {
          do {
            guard !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            try AICredentialStore.save(token)
            token = ""
            status = "Token saved securely. Retry your message to connect."
          } catch { status = error.localizedDescription }
        }
        .novaActionColor()
        Button("Remove saved token", role: .destructive) {
          do {
            try AICredentialStore.save("")
            status = "Token removed."
          } catch { status = error.localizedDescription }
        }
        .novaActionColor(.red)
      } header: {
        Text("Access token")
          .font(NovaTheme.Typography.headline)
          .textCase(nil)
          .foregroundStyle(NovaTheme.textSecondary)
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
      if let status {
        Text(status)
          .font(.footnote)
          .foregroundStyle(NovaTheme.textSecondary)
          .listRowBackground(NovaTheme.surface)
          .listRowSeparatorTint(NovaTheme.border)
      }
    }
    .novaGroupedListSpacing()
    .novaScreen()
    .novaNavigationTitle("AI Connection")
    .onDisappear { token = "" }
  }
}
