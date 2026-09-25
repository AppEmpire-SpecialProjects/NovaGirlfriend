import SwiftUI

struct ChatLaunchContext: Hashable, Sendable {
    let character: CharacterProfile
    let scenario: Scenario?
}

struct ChatLaunchAction {
    let callAsFunction: (ChatLaunchContext) -> Void

    func callAsFunction(_ context: ChatLaunchContext) {
        callAsFunction(context)
    }
}

private struct ChatLaunchActionKey: EnvironmentKey {
    static let defaultValue = ChatLaunchAction { _ in }
}

extension EnvironmentValues {
    var launchChat: ChatLaunchAction {
        get { self[ChatLaunchActionKey.self] }
        set { self[ChatLaunchActionKey.self] = newValue }
    }
}
