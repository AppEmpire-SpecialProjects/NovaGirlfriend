import SwiftUI

struct MessageBubble: View {
  let message: MessageRecord
  let isThinking: Bool
  let playingFile: String?
  let retry: () -> Void
  let play: (String) -> Void
  let speak: () -> Void
  private var isUser: Bool { message.roleRawValue == "user" }

  var body: some View {
    HStack {
      if isUser { Spacer(minLength: 32) }
      VStack(alignment: .leading, spacing: 10) {
        if !message.text.isEmpty {
          Text(message.text)
            .font(NovaTheme.Typography.body)
            .foregroundStyle(isUser ? NovaTheme.outgoingMessageText : NovaTheme.text)
            .lineSpacing(3)
            .textSelection(.enabled)
        }
        if let file = message.audioFileName {
          Button(playingFile == file ? "Stop audio" : "Play audio", systemImage: "waveform") {
            play(file)
          }
          .foregroundStyle(isUser ? NovaTheme.outgoingMessageText : NovaTheme.primary)
        }
        ViewThatFits(in: .horizontal) {
          HStack(spacing: 10) { metadata }
          VStack(alignment: .leading, spacing: 8) { metadata }
        }
        .font(NovaTheme.Typography.caption)
        .foregroundStyle(
          isUser ? NovaTheme.outgoingMessageSecondaryText : NovaTheme.textSecondary)
      }
      .padding(NovaTheme.Spacing.medium)
      .background(
        isUser ? NovaTheme.outgoingMessage : NovaTheme.surface,
        in: RoundedRectangle(cornerRadius: NovaTheme.Radius.medium)
      )
      if !isUser { Spacer(minLength: 32) }
    }
  }

  @ViewBuilder
  private var metadata: some View {
    Text(message.createdAt, style: .time)
    if isUser {
      Text(
        message.deliveryStateRawValue == "pending"
          ? "Sending…" : message.deliveryStateRawValue.capitalized
      )
      if message.deliveryStateRawValue == "failed" {
        Button("Retry", action: retry)
          .foregroundStyle(NovaTheme.outgoingMessageText)
          .disabled(isThinking)
      }
    } else {
      Button(action: speak) { Image(systemName: "speaker.wave.2") }
        .foregroundStyle(NovaTheme.primary)
        .accessibilityLabel("Read response aloud")
    }
  }
}
