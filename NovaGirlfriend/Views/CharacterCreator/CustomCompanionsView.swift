import SwiftData
import SwiftUI

struct CustomCompanionsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \CharacterRecord.createdAt) private var records: [CharacterRecord]
  @State private var showsCreator = false
  @State private var editorProfile: CharacterProfile?
  @State private var createdProfile: CharacterProfile?
  @State private var pendingCreatedProfile: CharacterProfile?
  @State private var pendingDelete: CharacterProfile?
  @State private var errorMessage: String?
  private let content = ProductContentRepository()

  private var customRecords: [CharacterRecord] {
    records.filter { $0.originRawValue == CharacterOrigin.custom.rawValue }
  }

  var body: some View {
    Group {
      if customRecords.isEmpty {
        NovaEmptyState(
          title: "No Custom Companions",
          message:
            "Create a companion with your own identity, personality, appearance, and system voice.",
          systemImage: "person.crop.circle.badge.plus",
          actionTitle: "Create Companion", action: presentCreator)
      } else {
        List(customRecords) { record in
          let profile = record.profile
          NavigationLink(value: profile) {
            HStack(spacing: NovaTheme.Spacing.medium) {
              CharacterAvatarView(profile: profile)
              VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
                Text(profile.name).font(NovaTheme.Typography.headline)
                Text(profile.tagline).font(.subheadline).foregroundStyle(NovaTheme.textSecondary)
              }
            }
            .padding(.vertical, NovaTheme.Spacing.extraSmall)
          }
          .listRowBackground(NovaTheme.surface)
          .listRowSeparatorTint(NovaTheme.border)
          .swipeActions(edge: .trailing) {
            Button("Delete", systemImage: "trash", role: .destructive) {
              pendingDelete = profile
            }
            Button("Edit", systemImage: "pencil") {
              presentEditor(profile)
            }
            .tint(NovaTheme.primary)
          }
          .contextMenu {
            Button("Edit", systemImage: "pencil") { presentEditor(profile) }
            Button("Duplicate", systemImage: "plus.square.on.square") { duplicate(profile) }
            Button("Delete", systemImage: "trash", role: .destructive) {
              pendingDelete = profile
            }
          }
        }
        .listStyle(.insetGrouped)
        .novaGroupedListSpacing()
      }
    }
    .novaScreen()
    .novaNavigationTitle("My Companions")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button("Create", systemImage: "plus") { presentCreator() }
          .novaActionColor()
      }
    }
    .fullScreenCover(
      isPresented: $showsCreator,
      onDismiss: {
        editorProfile = nil
        createdProfile = pendingCreatedProfile
        pendingCreatedProfile = nil
      }
    ) {
      CharacterCreatorView(profile: editorProfile) { profile in
        if editorProfile == nil {
          pendingCreatedProfile = profile
        }
        showsCreator = false
      }
    }
    .navigationDestination(for: CharacterProfile.self) { profile in
      CustomCompanionDetailView(characterID: profile.id)
    }
    .navigationDestination(item: $createdProfile) { profile in
      CustomCompanionDetailView(characterID: profile.id)
    }
    .confirmationDialog(
      "Delete this companion?",
      isPresented: Binding(
        get: { pendingDelete != nil },
        set: { if !$0 { pendingDelete = nil } }
      ),
      titleVisibility: .visible
    ) {
      Button("Delete Companion", role: .destructive) { deletePendingCompanion() }
      Button("Cancel", role: .cancel) { pendingDelete = nil }
    } message: {
      Text(
        "This removes the companion and its locally stored custom avatar. This cannot be undone.")
    }
    .alert(
      "Couldn’t Complete Action",
      isPresented: Binding(
        get: { errorMessage != nil },
        set: { if !$0 { errorMessage = nil } }
      )
    ) {
      Button("OK") { errorMessage = nil }
    } message: {
      Text(errorMessage ?? "Unknown error")
    }
  }

  private func presentCreator() {
    editorProfile = nil
    showsCreator = true
  }

  private func presentEditor(_ profile: CharacterProfile) {
    editorProfile = profile
    showsCreator = true
  }

  private func duplicate(_ profile: CharacterProfile) {
    do {
      let newID = UUID()
      let copy = CharacterProfile(
        id: newID,
        name: "\(profile.name) Copy",
        gender: profile.gender,
        tagline: profile.tagline,
        biography: profile.biography,
        avatarAssetName: try AvatarStorage.duplicate(
          reference: profile.avatarAssetName,
          characterID: newID
        ),
        symbolName: profile.symbolName,
        accentHex: profile.accentHex,
        personality: profile.personality,
        preferredScenarioID: profile.preferredScenarioID,
        voice: profile.voice,
        origin: .custom
      )
      try SwiftDataCharacterRepository(context: modelContext).saveCustom(copy)
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func deletePendingCompanion() {
    guard let profile = pendingDelete else { return }
    do {
      try SwiftDataCharacterRepository(context: modelContext).deleteCustom(id: profile.id)
      pendingDelete = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
