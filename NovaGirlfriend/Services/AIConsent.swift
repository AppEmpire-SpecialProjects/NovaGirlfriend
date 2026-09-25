import Combine
import SwiftUI

/// One-time consent for sending user content to the AI processing service.
/// Without it no AI feature (replies, transcription, companion voice) runs.
enum AIConsent {
  static let key = "preferences.aiDataProcessingConsent"

  static let title: LocalizedStringKey = "AI Data Processing"

  static let message: LocalizedStringKey = """
    To provide AI features, the app sends your messages, attached photos, voice recordings and \
    your companion’s personality to our AI processing service to generate replies and voice.

    By tapping Continue, you agree to share this data so your request can be processed. \
    Companions are AI characters, and their replies may be inaccurate.
    """

  static func isGranted(in defaults: UserDefaults = .standard) -> Bool {
    defaults.bool(forKey: key)
  }

  static func grant(in defaults: UserDefaults = .standard) {
    defaults.set(true, forKey: key)
  }
}

/// Runs an AI action right away when consent exists, otherwise asks first
/// and runs the action only after the user taps Continue.
@MainActor
final class AIConsentGate: ObservableObject {
  @Published var isPresented = false
  private var pendingAction: (() -> Void)?

  func run(_ action: @escaping () -> Void) {
    if AIConsent.isGranted() {
      action()
    } else {
      pendingAction = action
      isPresented = true
    }
  }

  func confirm() {
    AIConsent.grant()
    let action = pendingAction
    pendingAction = nil
    action?()
  }

  func cancel() {
    pendingAction = nil
  }
}

extension View {
  func aiConsentAlert(_ gate: AIConsentGate) -> some View {
    modifier(AIConsentAlertModifier(gate: gate))
  }
}

private struct AIConsentAlertModifier: ViewModifier {
  @ObservedObject var gate: AIConsentGate

  func body(content: Content) -> some View {
    content.alert(AIConsent.title, isPresented: $gate.isPresented) {
      Button("Cancel", role: .cancel) { gate.cancel() }
      Button("Continue") { gate.confirm() }
        .accessibilityIdentifier("aiConsent.continue")
    } message: {
      Text(AIConsent.message)
    }
  }
}
