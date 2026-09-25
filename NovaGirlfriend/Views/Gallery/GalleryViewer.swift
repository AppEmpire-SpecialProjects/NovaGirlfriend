import SwiftData
import SwiftUI

struct GalleryViewer: View {
  let item: GalleryDisplayItem
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var context
  @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
  @AppStorage("preferences.reduceMotion") private var prefersReducedMotion = false
  private var motion: GalleryMotion {
    GalleryMotion(systemReduceMotion: systemReduceMotion, appReduceMotion: prefersReducedMotion)
  }
  @Query private var records: [GalleryItemRecord]
  @State private var isSharing = false
  @State private var error: String?

  init(item: GalleryDisplayItem) {
    self.item = item
    let id = item.id
    _records = Query(filter: #Predicate<GalleryItemRecord> { $0.id == id })
  }

  private var isSaved: Bool { records.first?.isSaved ?? item.isSaved }

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 12) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .font(.system(size: 17, weight: .semibold))
            .frame(width: 44, height: 44)
            .background(NovaTheme.surface, in: Circle())
        }
        .accessibilityLabel("Close")
        .accessibilityIdentifier("gallery.viewer.close")
        VStack(alignment: .leading, spacing: 4) {
          Text(item.character.name)
            .font(.headline)
          Text(item.title)
            .font(.subheadline)
            .foregroundStyle(NovaTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(16)
      GeometryReader { geometry in
        Image(uiImage: item.image)
          .resizable()
          .scaledToFit()
          .frame(width: geometry.size.width, height: geometry.size.height)
          .contentShape(Rectangle())
          .gesture(
            DragGesture(minimumDistance: 40).onEnded { value in
              if value.translation.height > 100,
                abs(value.translation.width) < value.translation.height
              {
                dismiss()
              }
            }
          )
          .accessibilityLabel("\(item.title), artwork of \(item.character.name)")
          .accessibilityIdentifier("gallery.viewer.image")
      }
      HStack(spacing: 16) {
        Button(action: toggleSaved) {
          Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "heart.fill" : "heart")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSaved ? NovaTheme.primary : NovaTheme.text)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(NovaTheme.surface, in: Capsule())
            .animation(motion.animation(.easeOut(duration: 0.18)), value: isSaved)
        }
        .accessibilityLabel(isSaved ? "Unsave Moment" : "Save Moment")
        .accessibilityIdentifier("gallery.viewer.save")
        Button {
          isSharing = true
        } label: {
          Label("Share", systemImage: "square.and.arrow.up")
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(NovaTheme.surface, in: Capsule())
        }
        .accessibilityIdentifier("gallery.viewer.share")
      }
      .padding(20)
    }
    .buttonStyle(.plain)
    .foregroundStyle(NovaTheme.text)
    .background(Color.black.ignoresSafeArea())
    .preferredColorScheme(.dark)
    .statusBarHidden()
    .sheet(isPresented: $isSharing) {
      GalleryImageShareSheet(image: item.image)
        .presentationDetents([.medium, .large])
    }
    .alert(
      "Couldn’t save this moment",
      isPresented: Binding(
        get: { error != nil }, set: { if !$0 { error = nil } }
      )
    ) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(error ?? "Please try again.")
    }
    .transaction { transaction in
      motion.apply(to: &transaction)
    }
  }

  private func toggleSaved() {
    do {
      let repository = SwiftDataGalleryRepository(context: context)
      try repository.reconcile()
      try repository.setSaved(!isSaved, id: item.id)
    } catch {
      self.error = error.localizedDescription
    }
  }
}

private struct GalleryImageShareSheet: UIViewControllerRepresentable {
  let image: UIImage

  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: [image], applicationActivities: nil)
  }

  func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
