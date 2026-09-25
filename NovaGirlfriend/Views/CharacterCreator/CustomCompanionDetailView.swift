import SwiftData
import SwiftUI

struct CustomCompanionDetailView: View {
  let characterID: UUID
  var onDelete: (() -> Void)? = nil
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss
  @Environment(\.launchChat) private var launchChat
  @Query private var records: [CharacterRecord]
  @State private var editing = false
  @State private var confirmsDelete = false
  @State private var error: String?
  @State private var showPremiumPaywall = false
  @State private var duplicateID: UUID?

  private var profile: CharacterProfile? {
    records.first { $0.id == characterID }?.profile
  }

  var body: some View {
    Group {
      if let profile {
        ScrollView {
          VStack(alignment: .leading, spacing: NovaTheme.Spacing.sectionGap) {
            VStack(alignment: .leading, spacing: NovaTheme.Spacing.medium) {
              CharacterAvatarView(profile: profile, size: 160)
                .frame(maxWidth: .infinity)
                .padding(.vertical, NovaTheme.Spacing.medium)
              VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
                Text(profile.name)
                  .font(NovaTheme.Typography.display)
                  .foregroundStyle(NovaTheme.text)
                Text(profile.biography)
                  .font(NovaTheme.Typography.body)
                  .foregroundStyle(NovaTheme.textSecondary)
                  .fixedSize(horizontal: false, vertical: true)
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(NovaTheme.Spacing.medium)
            .novaSurface()
            NovaPrimaryButton("Chat with \(profile.name)", systemImage: "bubble.left.fill") {
              launchChat(ChatLaunchContext(character: profile, scenario: nil))
            }
            VStack(alignment: .leading, spacing: NovaTheme.Spacing.medium) {
              NavigationLink("View Full Profile") {
                CharacterDetailView(
                  character: profile, scenarios: ProductContentRepository().scenarios)
              }
              Divider()
              Button("Edit Companion") { editing = true }
                .buttonStyle(NovaSecondaryButtonStyle())
              Button("Duplicate Companion") { duplicate(profile) }
                .buttonStyle(NovaSecondaryButtonStyle())
              Button("Delete Companion", role: .destructive) { confirmsDelete = true }
                .buttonStyle(NovaSecondaryButtonStyle())
            }
            .font(NovaTheme.Typography.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(NovaTheme.Spacing.medium)
            .novaSurface()
          }
          .padding(NovaTheme.Spacing.screenMargin)
        }
        .sheet(isPresented: $editing) {
          CharacterCreatorView(profile: profile) { _ in }
        }
      } else {
        NovaEmptyState(
          title: "Companion unavailable", systemImage: "person.crop.circle.badge.questionmark")
      }
    }
    .novaScreen()
    .toolbar(.hidden, for: .tabBar)
    .novaNavigationTitle(profile?.name ?? "Companion")
    .fullScreenCover(isPresented: $showPremiumPaywall) {
      PremiumPaywallView { _ in showPremiumPaywall = false }
    }
    .confirmationDialog(
      "Delete this companion?", isPresented: $confirmsDelete,
      titleVisibility: .visible
    ) {
      Button("Delete Companion", role: .destructive) {
        do {
          try SwiftDataCharacterRepository(context: context).deleteCustom(id: characterID)
          if let onDelete {
            onDelete()
          } else {
            dismiss()
          }
        } catch {
          self.error = error.localizedDescription
        }
      }
      .accessibilityIdentifier("companion.confirmDelete")
    } message: {
      Text("This removes the companion, its conversations and saved moments. This cannot be undone.")
    }
    .alert(
      "Couldn’t Complete Action",
      isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })
    ) {
      Button("OK") { error = nil }
    } message: {
      Text(error ?? "")
    }
    .navigationDestination(
      isPresented: Binding(get: { duplicateID != nil }, set: { if !$0 { duplicateID = nil } })
    ) {
      if let duplicateID {
        CustomCompanionDetailView(characterID: duplicateID) {
          self.duplicateID = nil
        }
      }
    }
  }

  private func duplicate(_ profile: CharacterProfile) {
    let id = UUID()
    var avatar: String?
    do {
      let repository = SwiftDataCharacterRepository(context: context)
      try AccessPolicy.shared.requireCompanionCreation(
        existingCount: repository.customCharacters().count)
      avatar = try AvatarStorage.duplicate(reference: profile.avatarAssetName, characterID: id)
      let copy = CharacterProfile(
        id: id,
        name: profile.name + " Copy",
        gender: profile.gender,
        tagline: profile.tagline,
        biography: profile.biography,
        avatarAssetName: avatar,
        symbolName: profile.symbolName,
        accentHex: profile.accentHex,
        personality: profile.personality,
        preferredScenarioID: profile.preferredScenarioID,
        voice: profile.voice,
        origin: .custom
      )
      try SwiftDataCharacterRepository(context: context).saveCustom(copy)
      duplicateID = id
    } catch {
      if avatar != profile.avatarAssetName { AvatarStorage.delete(reference: avatar) }
      if error is AccessPolicy.Denial {
        showPremiumPaywall = true
      } else {
        self.error = error.localizedDescription
      }
    }
  }
}
