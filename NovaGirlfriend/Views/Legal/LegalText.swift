import Foundation

enum LegalDocument: String, Identifiable {
    case privacy = "Privacy Policy"
    case terms = "Terms of Use"

    var id: String { rawValue }

    var body: String {
        switch self {
        case .privacy: LegalText.privacy
        case .terms: LegalText.terms
        }
    }
}

enum LegalText {
    static let privacy = """
    Last updated: September 8, 2026

    Nova is designed to keep your data under your control. Companion profiles, imported avatar copies, conversation history, and preferences are stored locally on your device unless you explicitly use a service or share an export.

    Photos
    When you choose an avatar, Apple’s photo picker gives Nova access only to the item you select. Nova copies that image into private app storage. It is not uploaded by the avatar feature.

    Microphone and speech
    Nova requests microphone or speech-recognition permission only when you use a related feature. System text-to-speech playback is performed using voices installed on your device.

    AI conversations
    If an AI service is configured and you send a message, the conversation context required to generate a reply may be sent to that configured service. Do not include information you do not want processed by that service.

    Sharing and export
    Export and share actions use Apple’s system share sheet. You choose the destination. Nova does not silently export your data.

    Deletion
    You can delete custom companions and conversations in the app. Deleting the app removes its local container, subject to iOS backup behavior.
    """

    static let terms = """
    Last updated: September 8, 2026

    By using Nova, you agree to use it lawfully and responsibly. Nova provides companion and creative conversation features and is not a substitute for professional medical, legal, financial, or emergency advice.

    You remain responsible for the content you submit, create, or share and for ensuring you have rights to imported images. Do not use Nova to harm others, violate rights, or attempt unauthorized access.

    AI-generated responses may be incomplete or inaccurate. Verify important information independently. Service availability can vary based on device capabilities, permissions, network access, and configured providers.

    The app and its features are provided without a guarantee of uninterrupted availability. These terms do not limit rights that cannot be limited under applicable consumer law.
    """
}
