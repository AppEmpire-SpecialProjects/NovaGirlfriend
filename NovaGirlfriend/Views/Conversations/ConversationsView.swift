import SwiftData
import SwiftUI

struct ConversationsView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.launchChat) private var launchChat
  @Query(sort: \ConversationRecord.updatedAt, order: .reverse) private var conversations:
    [ConversationRecord]
  @Query(sort: \CharacterRecord.createdAt) private var characterRecords: [CharacterRecord]
  @State private var search = ""
  @FocusState private var searchIsFocused: Bool
  @State private var showNew = false
  @State private var pendingNewCharacter: CharacterProfile?
  @State private var pendingDelete: ConversationRecord?
  @State private var error: String?

  private var characters: [CharacterProfile] {
    let customCharacters =
      characterRecords
      .filter { $0.originRawValue == CharacterOrigin.custom.rawValue }
      .map(\.profile)
    return ProductContentRepository().characters + customCharacters
  }

  private var filtered: [ConversationRecord] {
    conversations.filter {
      search.isEmpty || $0.title.localizedCaseInsensitiveContains(search)
        || $0.messages.contains { $0.text.localizedCaseInsensitiveContains(search) }
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Image(systemName: "magnifyingglass").foregroundStyle(NovaTheme.inactiveIcon)
        TextField(
          "Search conversations and messages", text: $search,
          prompt: Text("Search conversations and messages").foregroundStyle(NovaTheme.textTertiary)
        )
        .focused($searchIsFocused)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .accessibilityIdentifier("conversations.search")
        if !search.isEmpty {
          Button("Clear search", systemImage: "xmark.circle.fill") { search = "" }
            .labelStyle(.iconOnly)
            .novaActionColor()
        }
      }
      .padding(12)
      .novaInput(cornerRadius: 12, isFocused: searchIsFocused)
      .padding(.horizontal, NovaTheme.Spacing.screenMargin)
      .padding(.vertical, NovaTheme.Spacing.screenMargin)
      scenariosCallout
        .padding(.horizontal, NovaTheme.Spacing.screenMargin)
        .padding(.bottom, NovaTheme.Spacing.sectionGap)
      conversationList
    }
    .novaScreen()
    .novaNavigationTitle("Conversations")
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          searchIsFocused = false
          pendingNewCharacter = nil
          showNew = true
        } label: {
          Image(systemName: "plus")
        }
        .novaActionColor()
        .accessibilityLabel("New conversation")
        .accessibilityHint("Choose a companion to start a new chat")
        .accessibilityIdentifier("conversations.newChat")
      }
    }
    .sheet(isPresented: $showNew, onDismiss: startNewConversation) {
      newConversationSheet
    }
    .confirmationDialog(
      "Delete this conversation and its recordings?",
      isPresented: Binding(
        get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }
      ), titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        guard let pendingDelete else { return }
        do { try ConversationMaintenance(context: context).delete(pendingDelete) } catch {
          self.error = error.localizedDescription
        }
        self.pendingDelete = nil
      }
    }
  }

  private var scenariosCallout: some View {
    NavigationLink {
      ScenariosView(scenarios: ProductContentRepository().scenarios, characters: characters)
    } label: {
      HStack(spacing: NovaTheme.Spacing.medium) {
        ZStack {
          RoundedRectangle(cornerRadius: NovaTheme.Radius.small)
            .fill(NovaTheme.surface)
          Image(systemName: "sparkles.rectangle.stack.fill")
            .font(.title2)
            .foregroundStyle(NovaTheme.primary)
        }
        .frame(width: 54, height: 54)
        .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
          Text("Explore scenarios")
            .font(NovaTheme.Typography.headline)
          Text("Set the tone before a conversation")
            .font(.subheadline)
            .foregroundStyle(NovaTheme.textSecondary)
        }
        .foregroundStyle(NovaTheme.text)
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundStyle(NovaTheme.primary)
      }
      .padding(NovaTheme.Spacing.medium)
      .novaSurface()
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier("conversations.scenarios")
    .accessibilityHint("Opens all scenarios")
  }

  private var conversationList: some View {
    List {
      if let error {
        Text(error)
          .foregroundStyle(.red)
          .listRowBackground(NovaTheme.background)
      }
      ForEach(filtered) { conversation in
        Group {
          if let character = characters.first(where: { $0.id == conversation.characterID }) {
            NavigationLink {
              ChatView(
                character: character,
                scenario: ProductContentRepository().scenarios.first {
                  $0.id == conversation.scenarioID
                },
                existingConversation: conversation)
            } label: {
              conversationRow(conversation, character: character)
            }
            .accessibilityIdentifier("conversation.open")
          } else {
            conversationRow(conversation, character: nil)
          }
        }
        .listRowInsets(
          EdgeInsets(
            top: 12, leading: NovaTheme.Spacing.screenMargin,
            bottom: 12, trailing: NovaTheme.Spacing.screenMargin)
        )
        .listRowBackground(NovaTheme.background)
        .listRowSeparatorTint(NovaTheme.border)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 68 }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
          Button {
            pendingDelete = conversation
          } label: {
            Label("Delete", systemImage: "trash")
          }
          .tint(.red)
          .accessibilityLabel("Delete conversation \(conversation.title)")
        }
        .accessibilityAction(named: Text("Delete conversation")) {
          pendingDelete = conversation
        }
      }
    }
    .listStyle(.plain)
    .listRowSpacing(0)
    .contentMargins(.horizontal, 0, for: .scrollContent)
    .contentMargins(.top, 0, for: .scrollContent)
    .contentMargins(.bottom, NovaTheme.Spacing.screenMargin, for: .scrollContent)
    .scrollContentBackground(.hidden)
    .scrollDismissesKeyboard(.interactively)
    .background(NovaTheme.background)
    .overlay {
      if filtered.isEmpty {
        NovaEmptyState(
          title: search.isEmpty ? "No conversations yet" : "No matches",
          message: "Start a conversation with a companion using the + button.",
          systemImage: "bubble.left.and.bubble.right")
      }
    }
  }

  private var newConversationSheet: some View {
    NavigationStack {
      List(characters) { character in
        Button {
          pendingNewCharacter = character
          showNew = false
        } label: {
          HStack(spacing: NovaTheme.Spacing.medium) {
            CharacterAvatarView(profile: character, size: 46)
              .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
              Text(character.name)
                .font(NovaTheme.Typography.headline)
                .foregroundStyle(NovaTheme.text)
              Text(character.tagline)
                .font(.subheadline)
                .foregroundStyle(NovaTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
          }
          .padding(.vertical, NovaTheme.Spacing.extraSmall)
          .contentShape(Rectangle())
        }
        .listRowBackground(NovaTheme.surface)
        .listRowSeparatorTint(NovaTheme.border)
        .accessibilityLabel(character.name)
        .accessibilityIdentifier("conversations.chooseCharacter")
        .accessibilityHint("Starts a new chat with \(character.name)")
      }
      .novaGroupedListSpacing()
      .novaScreen()
      .novaNavigationTitle("Choose a companion")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", role: .cancel) { showNew = false }
            .novaActionColor()
        }
      }
    }
  }

  private func startNewConversation() {
    guard let character = pendingNewCharacter else { return }
    pendingNewCharacter = nil
    launchChat(ChatLaunchContext(character: character, scenario: nil))
  }

  private func conversationRow(
    _ conversation: ConversationRecord, character: CharacterProfile?
  ) -> some View {
    HStack(spacing: 12) {
      Group {
        if let character {
          CharacterAvatarView(profile: character, size: 56)
        } else {
          Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(NovaTheme.inactiveIcon)
            .frame(width: 56, height: 56)
        }
      }
      .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: NovaTheme.Spacing.titleSubtitle) {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text(conversation.title)
            .font(.body.weight(.semibold))
            .foregroundStyle(NovaTheme.text)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
          conversationTimestamp(conversation.updatedAt)
            .font(.subheadline)
            .foregroundStyle(NovaTheme.textSecondary)
            .lineLimit(1)
            .fixedSize()
        }
        Group {
          if character == nil {
            Text("Character unavailable")
          } else {
            Text(
              conversation.orderedMessages.last.map { $0.text.isEmpty ? "Voice message" : $0.text }
                ?? "Start the conversation"
            )
          }
        }
        .font(.subheadline)
        .foregroundStyle(NovaTheme.textSecondary)
        .lineLimit(2, reservesSpace: true)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .contentShape(Rectangle())
  }

  @ViewBuilder
  private func conversationTimestamp(_ date: Date) -> some View {
    if Calendar.current.isDateInToday(date) {
      Text(date, style: .time)
    } else if Calendar.current.isDateInYesterday(date) {
      Text("Yesterday")
    } else {
      Text(date, format: .dateTime.day().month(.twoDigits).year(.twoDigits))
    }
  }
}
