import SwiftData
import SwiftUI

struct SettingsView: View {
  @Query private var companions: [CharacterRecord]
  @Query private var conversations: [ConversationRecord]
  @State private var legalDocument: LegalDocument?
  private let configuration = AppConfiguration()

  private var customCompanionCount: Int {
    companions.filter { $0.originRawValue == CharacterOrigin.custom.rawValue }.count
  }

  var body: some View {
    List {
      Section {
        NavigationLink {
          CustomCompanionsView()
            .toolbar(.hidden, for: .tabBar)
        } label: {
          SettingsRow(
            title: "My Companions", systemImage: "person.2",
            detail: customCompanionCount.formatted())
        }
        NavigationLink {
          ConversationsView()
            .toolbar(.hidden, for: .tabBar)
        } label: {
          SettingsRow(
            title: "Conversation History", systemImage: "bubble.left.and.bubble.right",
            detail: conversations.count.formatted())
        }
        NavigationLink {
          DataExportView()
        } label: {
          SettingsRow(title: "Export Data", systemImage: "square.and.arrow.up")
        }
      } header: {
        sectionHeader("Companions & Conversations")
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)

      Section {
        NavigationLink {
          VoiceSettingsView()
        } label: {
          SettingsRow(title: "Voice Settings", systemImage: "waveform")
        }
        NavigationLink {
          ExperienceSettingsView()
        } label: {
          SettingsRow(title: "Experience", systemImage: "slider.horizontal.3")
        }
      } header: {
        sectionHeader("Preferences")
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)

      if configuration.reviewURL != nil || configuration.appStoreURL != nil
        || configuration.supportURL != nil
      {
        Section {
          if let reviewURL = configuration.reviewURL {
            Link(destination: reviewURL) {
              SettingsRow(title: "Rate Nova", systemImage: "star")
            }
          }
          if let appStoreURL = configuration.appStoreURL {
            ShareLink(item: appStoreURL) {
              SettingsRow(title: "Share Nova", systemImage: "square.and.arrow.up")
            }
          }
          if let supportURL = configuration.supportURL {
            Link(destination: supportURL) {
              SettingsRow(title: "Contact Support", systemImage: "envelope")
            }
          }
        } header: {
          sectionHeader("Support")
        }
        .listRowBackground(NovaTheme.surface)
        .listRowSeparatorTint(NovaTheme.border)
      }

      Section {
        Button {
          legalDocument = .privacy
        } label: {
          SettingsRow(title: "Privacy Policy", systemImage: "hand.raised")
        }
        Button {
          legalDocument = .terms
        } label: {
          SettingsRow(title: "Terms of Use", systemImage: "doc.text")
        }
        NavigationLink {
          AboutView()
        } label: {
          SettingsRow(title: "About Nova", systemImage: "info.circle")
        }
      } header: {
        sectionHeader("About & Legal")
      }
      .listRowBackground(NovaTheme.surface)
      .listRowSeparatorTint(NovaTheme.border)
    }
    .listStyle(.insetGrouped)
    .novaGroupedListSpacing()
    .novaScreen()
    .novaNavigationTitle("Settings")
    .sheet(item: $legalDocument) { document in
      LegalSheetView(document: document)
    }
  }

  private func sectionHeader(_ title: LocalizedStringKey) -> some View {
    Text(title)
      .font(NovaTheme.Typography.headline)
      .textCase(nil)
      .foregroundStyle(NovaTheme.textSecondary)
  }
}

private struct SettingsRow: View {
  let title: LocalizedStringKey
  let systemImage: String
  var detail: String? = nil
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    HStack(alignment: .top, spacing: NovaTheme.Spacing.medium) {
      Image(systemName: systemImage)
        .foregroundStyle(NovaTheme.primary)
        .frame(width: 32, height: 32)
        .background(
          NovaTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: NovaTheme.Radius.small)
        )
        .accessibilityHidden(true)
      if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
          Text(title).foregroundStyle(NovaTheme.text)
          if let detail {
            Text(detail)
              .font(NovaTheme.Typography.caption)
              .foregroundStyle(NovaTheme.textSecondary)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      } else {
        Text(title).foregroundStyle(NovaTheme.text)
        Spacer()
        if let detail {
          Text(detail).foregroundStyle(NovaTheme.textSecondary)
        }
      }
    }
    .font(NovaTheme.Typography.body)
    .padding(.vertical, NovaTheme.Spacing.extraSmall)
    .contentShape(Rectangle())
  }
}
