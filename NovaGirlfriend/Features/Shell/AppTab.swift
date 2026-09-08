import SwiftUI

enum AppTab: Hashable, CaseIterable {
    case discover
    case conversations
    case gallery
    case settings

    var title: LocalizedStringKey {
        switch self {
        case .discover: "Discover"
        case .conversations: "Conversations"
        case .gallery: "Gallery"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .discover: "person.2.fill"
        case .conversations: "bubble.left.and.bubble.right.fill"
        case .gallery: "photo.on.rectangle.angled"
        case .settings: "gearshape.fill"
        }
    }
}
