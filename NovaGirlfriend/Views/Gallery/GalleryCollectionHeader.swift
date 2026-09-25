import SwiftUI

struct GalleryCompanionSelector: View {
  let characters: [CharacterProfile]
  var favoriteIDs: Set<UUID> = []
  let selectedID: UUID
  let select: (UUID) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Choose Companion")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(NovaTheme.textSecondary)
        .padding(.horizontal, 16)
      ScrollViewReader { proxy in
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(alignment: .top, spacing: 18) {
            ForEach(characters) { character in
              let selected = character.id == selectedID
              let favorite = favoriteIDs.contains(character.id)
              Button {
                select(character.id)
              } label: {
                VStack(spacing: 8) {
                  CharacterAvatarView(profile: character, size: 68)
                    .padding(4)
                    .overlay {
                      Circle().strokeBorder(
                        selected ? NovaTheme.primary : .clear, lineWidth: 1.5)
                    }
                    .overlay(alignment: .bottomTrailing) {
                      if favorite {
                        Image(systemName: "heart.fill")
                          .font(.system(size: 11, weight: .bold))
                          .foregroundStyle(NovaTheme.primary)
                          .frame(width: 24, height: 24)
                          .background(NovaTheme.surface, in: Circle())
                          .overlay(Circle().strokeBorder(NovaTheme.border))
                      }
                    }
                  Text(character.name)
                    .font(.caption.weight(selected ? .semibold : .regular))
                    .foregroundStyle(selected ? NovaTheme.text : NovaTheme.textSecondary)
                    .lineLimit(2)
                    .frame(width: 84)
                  Circle()
                    .fill(selected ? NovaTheme.primary : .clear)
                    .frame(width: 4, height: 4)
                }
              }
              .buttonStyle(.plain)
              .id(character.id)
              .accessibilityLabel(character.name)
              .accessibilityValue(
                [favorite ? "Favorite" : nil, selected ? "Selected" : nil]
                  .compactMap { $0 }.joined(separator: ", "))
              .accessibilityAddTraits(selected ? .isSelected : [])
              .accessibilityIdentifier("gallery.companion.\(character.id.uuidString)")
            }
          }
          .padding(.horizontal, 16)
        }
        .accessibilityIdentifier("gallery.companions")
        .onAppear {
          proxy.scrollTo(selectedID, anchor: .center)
        }
        .onChange(of: selectedID) { _, id in
          proxy.scrollTo(id, anchor: .center)
        }
      }
    }
  }
}

struct GalleryCollectionSummary: View {
  let character: CharacterProfile
  let unlocked: Int
  let total: Int

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("\(character.name)’s Moments")
        .font(.title2.weight(.semibold))
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("gallery.collectionTitle")
      Text("A closer look at \(character.name), one moment at a time.")
        .font(.subheadline)
        .foregroundStyle(NovaTheme.textSecondary)
        .fixedSize(horizontal: false, vertical: true)
      if total > 0 {
        HStack(spacing: 12) {
          Text("\(unlocked) of \(total) unlocked")
            .font(.caption.weight(.medium))
            .foregroundStyle(NovaTheme.textSecondary)
            .accessibilityIdentifier("gallery.progress")
          GeometryReader { geometry in
            Capsule()
              .fill(.white.opacity(0.1))
              .overlay(alignment: .leading) {
                Capsule()
                  .fill(NovaTheme.primary)
                  .frame(width: geometry.size.width * CGFloat(unlocked) / CGFloat(total))
              }
          }
          .frame(maxWidth: 90)
          .frame(height: 3)
          .accessibilityHidden(true)
        }
        .padding(.top, 2)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct GalleryFilterChips: View {
  @Binding var selection: GalleryFilter

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(GalleryFilter.allCases) { filter in
          let selected = selection == filter
          Button {
            selection = filter
          } label: {
            Text(filter.rawValue)
              .font(.subheadline.weight(.semibold))
              .padding(.horizontal, 18)
              .frame(minHeight: 44)
              .foregroundStyle(selected ? NovaTheme.background : NovaTheme.textSecondary)
              .background(selected ? NovaTheme.primary : NovaTheme.surface, in: Capsule())
              .overlay {
                Capsule().strokeBorder(selected ? .clear : NovaTheme.border, lineWidth: 1)
              }
          }
          .buttonStyle(.plain)
          .accessibilityAddTraits(selected ? .isSelected : [])
          .accessibilityIdentifier("gallery.filter.\(filter.rawValue)")
        }
      }
      .padding(.horizontal, 16)
    }
    .accessibilityIdentifier("gallery.filters")
  }
}
