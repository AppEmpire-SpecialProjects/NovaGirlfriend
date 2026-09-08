import SwiftUI

struct OnboardingView: View {
  let onComplete: () -> Void

  @AppStorage("preferences.hapticsEnabled") private var hapticsEnabled = true
  @AppStorage("preferences.reduceMotion") private var prefersReducedMotion = false
  @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  private var reduceMotion: Bool { prefersReducedMotion || systemReduceMotion }
  @State private var page = 0

  private let pages = OnboardingPage.all

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Label("NOVA", systemImage: "sparkle")
          .font(NovaTheme.Typography.headline)
          .tracking(3)
          .foregroundStyle(NovaTheme.primary)
        Spacer()
        Text("\(page + 1) of \(pages.count)")
          .font(.subheadline.monospacedDigit())
          .foregroundStyle(NovaTheme.textSecondary)
      }
      .padding(.horizontal, NovaTheme.Spacing.screenMargin)
      .padding(.top, NovaTheme.Spacing.screenMargin)

      ProgressView(value: Double(page + 1), total: Double(pages.count))
        .tint(NovaTheme.primary)
        .padding(.horizontal, NovaTheme.Spacing.screenMargin)
        .padding(.top, NovaTheme.Spacing.small)
        .accessibilityLabel("Onboarding progress")
        .accessibilityValue("Page \(page + 1) of \(pages.count)")

      TabView(selection: $page) {
        ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
          OnboardingPageView(page: item)
            .tag(index)
            .padding(.horizontal, NovaTheme.Spacing.screenMargin)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.86), value: page)

      footerLayout {
        if page > 0 {
          Button("Back") {
            move(to: page - 1)
          }
          .buttonStyle(NovaSecondaryButtonStyle())
          .controlSize(.large)
          .accessibilityHint("Returns to the previous page")
        }

        NovaPrimaryButton(
          page == pages.count - 1 ? "Meet the characters" : "Continue",
          systemImage: page == pages.count - 1 ? "sparkles" : "arrow.right"
        ) {
          if page == pages.count - 1 {
            ExperienceFeedback.success(enabled: hapticsEnabled)
            onComplete()
          } else {
            move(to: page + 1)
          }
        }
        .accessibilityHint(
          page == pages.count - 1
            ? "Completes onboarding and opens Discover" : "Advances to the next page")
      }
      .padding(.horizontal, NovaTheme.Spacing.screenMargin)
      .padding(.bottom, NovaTheme.Spacing.screenMargin)
    }
    .background(NovaTheme.background.ignoresSafeArea())
    .novaScreen()
    .onChange(of: page) { _, _ in
      ExperienceFeedback.selection(enabled: hapticsEnabled)
    }
  }

  private var footerLayout: AnyLayout {
    dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(spacing: NovaTheme.Spacing.small))
      : AnyLayout(HStackLayout(spacing: NovaTheme.Spacing.medium))
  }

  private func move(to newPage: Int) {
    if reduceMotion {
      page = newPage
    } else {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
        page = newPage
      }
    }
  }
}

private struct OnboardingPageView: View {
  let page: OnboardingPage

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: NovaTheme.Spacing.sectionGap) {
        ZStack {
          RoundedRectangle(cornerRadius: NovaTheme.Radius.large)
            .fill(NovaTheme.surface)
          Circle()
            .strokeBorder(NovaTheme.border, lineWidth: 1)
            .frame(width: 150, height: 150)
          Image(systemName: page.symbolName)
            .font(.system(size: 56, weight: .light))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(page.tint)
        }
        .frame(height: 180)
        .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
          Text(page.title)
            .font(NovaTheme.Typography.display)
            .fixedSize(horizontal: false, vertical: true)
          Text(page.message)
            .font(NovaTheme.Typography.body)
            .foregroundStyle(NovaTheme.textSecondary)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
        }

        NovaCard {
          VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
            Label(page.noteTitle, systemImage: page.noteSymbol)
              .font(NovaTheme.Typography.headline)
              .foregroundStyle(page.tint)
            Text(page.note)
              .font(.subheadline)
              .foregroundStyle(NovaTheme.textSecondary)
              .fixedSize(horizontal: false, vertical: true)
          }
        }

      }
      .padding(.vertical, NovaTheme.Spacing.screenMargin)
    }
    .scrollIndicators(.hidden)
  }
}

private struct OnboardingPage {
  let title: LocalizedStringKey
  let message: LocalizedStringKey
  let symbolName: String
  let noteTitle: LocalizedStringKey
  let note: LocalizedStringKey
  let noteSymbol: String
  let tint: Color

  static let all: [OnboardingPage] = [
    OnboardingPage(
      title: "Meet your companion",
      message:
        "Discover distinct characters and choose the personality that feels right for this conversation.",
      symbolName: "person.2.fill",
      noteTitle: "Character-first",
      note: "Each companion has a clear voice, interests, and style. You decide who to meet.",
      noteSymbol: "heart.text.square",
      tint: NovaTheme.primary
    ),
    OnboardingPage(
      title: "Choose the moment",
      message:
        "Start naturally or add a scenario, from a coffee walk to an evening under the stars.",
      symbolName: "sparkles.rectangle.stack",
      noteTitle: "You set the context",
      note:
        "Scenarios guide the opening tone. They never pretend an event happened in the real world.",
      noteSymbol: "signpost.right.and.left",
      tint: NovaTheme.primary
    ),
    OnboardingPage(
      title: "Private by design",
      message:
        "Nothing is presented as your conversation, companion, or gallery item until you create or save it.",
      symbolName: "lock.shield.fill",
      noteTitle: "Always in control",
      note:
        "Microphone and photo access are requested only when you use a feature that needs them.",
      noteSymbol: "checkmark.shield",
      tint: NovaTheme.primary
    ),
  ]
}
