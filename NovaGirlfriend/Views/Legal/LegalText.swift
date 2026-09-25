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
    Last updated: September 22, 2026

    Nova provides AI companion conversations. Some data is stored on your device, but AI conversations, photo analysis, remote speech, and purchase management involve external services. Questions or privacy requests: work@lisas29.lat.

    Data stored on your device
    Nova stores companion profiles, imported avatar copies, conversation text, attached photo copies, recorded audio, remembered facts, relationship and achievement progress, and preferences in its local app storage. Access and usage information may also be stored to apply free and Premium feature limits. Local storage does not mean that content used with a remote feature stays only on your device.

    AI conversations and memory
    When you send a message, Nova sends the text and relevant conversation history to its remote AI service to generate a reply. Requests can include your companion’s profile and personality, scenario instructions, language preferences, and remembered facts about you. Nova also sends recent conversation text and existing remembered facts for AI-assisted memory extraction after completed exchanges. Resulting facts are saved locally and can be included in later conversations, including with other companions. You can review and delete saved facts in Settings → Memory. Do not submit sensitive information or other people’s personal data that you do not want processed remotely.

    Photos
    Apple’s photo picker lets you select images without giving Nova access to your entire photo library. Imported avatar copies are stored locally and are not uploaded by the avatar feature. Photos you attach and send for chat analysis are stored as local copies and sent to the remote AI service with the message context. These are separate uses: choosing an avatar is not the same as sending a photo in chat.

    Microphone and speech
    Nova requests microphone permission for recording and speech-recognition permission for transcription. Recordings are saved locally. Apple’s speech recognition may process audio on your device or through Apple’s services, depending on availability and system behavior; Nova does not require recognition to stay on-device. When Apple recognition is unavailable, fails, or produces no text, Nova can send recorded audio to its remote speech-recognition service. A transcript submitted in chat is processed as conversation text.

    Companion voice playback can send reply text, a voice identifier, and playback settings to a remote speech-synthesis service and download the generated audio for playback. This can happen while preparing an enabled spoken reply, before it is displayed. On-device system speech may be used as a fallback. Remote voice playback is not exclusively on-device processing.

    Purchases, identifiers, and Apphud
    Apple handles App Store billing. Nova uses Apphud through PremiumKit to load purchase offers, validate purchases, determine subscription access, and restore eligible purchases. Apple and Apphud process purchase and subscription information such as product and transaction identifiers and subscription status. Apphud may also process app-specific user or installation identifiers, device and app information, network information such as IP address, and paywall interaction events. The integration can send an Apple Ads attribution token to Apphud when available to attribute installations. These services operate under their own privacy policies, including Apple’s policy at https://www.apple.com/legal/privacy/ and Apphud’s policy at https://apphud.com/privacy.

    Remote processing and retention
    Content sent for AI, photo, or speech features is processed outside your device by the services that deliver those features. Network requests also expose connection information, such as your IP address, to the receiving services. This policy does not promise a particular remote retention period, processing location, exclusion from model training, or immediate server-side deletion. Local deletion does not recall requests already sent or establish that remote copies have been deleted. Contact work@lisas29.lat with questions or requests about remotely processed data; applicable rights and available actions depend on the data and service involved.

    Sharing and export
    Export and share actions use Apple’s system share sheet, where you choose the destination. The data export includes custom companion profile information and conversation text, not the underlying audio or image files. Copies you share are controlled by you and the receiving destination and are not removed when you delete data in Nova.

    Deletion and backups
    You can delete custom companions, clear or delete conversations, and separately delete remembered facts. Conversation clearing or deletion removes the relevant local message records and attempts to remove their attached recordings and photo copies. Deleting a custom companion removes its local profile and custom avatar copy; it does not automatically erase conversation history or remembered facts. Deleting a conversation does not automatically delete separately saved memories. A fact can be learned again if remaining or future conversation content contains it.

    Removing the app removes its local container, but offloading the app can preserve its data. Device or iCloud backups may retain copies according to your Apple settings, and restoring a backup may restore app data. Manage backups through Apple’s controls. In-app deletion does not delete exports, backup copies, Apple or Apphud purchase records, or content already processed remotely, and deleting the app does not cancel a subscription. Losing Premium access does not itself delete or hide your existing saved data.

    Contact
    For privacy questions and requests concerning access, correction, or deletion, email work@lisas29.lat. Avoid sending sensitive conversation content unless it is necessary for your request.
    """

    static let terms = """
    Last updated: September 22, 2026

    By using Nova, you agree to these Terms of Use. For questions or support, contact work@lisas29.lat.

    AI companion service
    Nova provides fictional AI companions and creative conversation features, not communication with a real person. AI responses, remembered facts, photo interpretations, and speech transcriptions may be inaccurate, incomplete, misleading, or inappropriate. Verify important information independently. Nova is not a substitute for professional medical, mental-health, legal, financial, or emergency advice. In an emergency, contact your local emergency services rather than relying on Nova.

    Responsible use
    You are responsible for the content you submit, create, or share, including having the necessary rights and permissions for images, recordings, and information about other people. Do not use Nova to harm others, violate the law or others’ rights, or attempt unauthorized access. Using remote features requires transmitting the relevant content as described in the Privacy Policy.

    Free and Premium access
    Free access includes 10 successful text replies per day and creation of one custom character. Failed reply attempts do not count as successful replies. Premium provides scenario features, photo analysis, remote speech features, and creation of more custom characters, with no daily text reply quota. No daily text quota does not guarantee uninterrupted or immediate service; network, technical, and service availability constraints still apply.

    Existing saved data remains accessible if you reach a free limit or Premium ends, including previously saved conversations and characters. Limits govern new replies and use of restricted features or creation of additional characters, not access to your saved data. Continued access assumes that the data remains on your device or is restored from your backup; a subscription is not a backup service.

    Prices and subscriptions
    Premium purchases are made through Apple’s App Store and managed in the app using Apphud through PremiumKit. Review the purchase screen and Apple’s confirmation for the actual price, currency, billing period, and any available introductory offer before confirming. Your Apple Account is charged according to the terms shown at purchase. A trial or introductory offer applies only if displayed and you are eligible; after it ends, the subscription renews at the disclosed price unless canceled in time.

    Auto-renewal and cancellation
    Auto-renewable subscriptions renew unless canceled at least 24 hours before the current period ends. Your Apple Account may be charged for renewal within 24 hours before the end of that period. Manage or cancel a subscription in iOS Settings → your name → Subscriptions. Cancellation normally stops future renewals while access continues for the remaining paid period, subject to Apple’s terms; trial access may end earlier under Apple’s rules. Deleting Nova, deleting local data, or stopping use does not cancel a subscription. Refund requests are handled through Apple, subject to its policies and applicable law.

    Restore purchases
    Use Restore Purchases in the app with the Apple Account used for the original purchase to recover eligible purchase access. Restoration depends on Apple’s purchase records and the current entitlement and may require a network connection. Restoring purchases does not restore deleted conversations, characters, recordings, photos, or other local data.

    Availability and your rights
    Features depend on device capabilities, permissions, network access, and external AI, speech, Apple, and Apphud services. Results and availability are not guaranteed, and remote requests can fail or be delayed. To the extent permitted by law, Nova is provided without a guarantee of uninterrupted or error-free operation. These terms do not exclude or limit rights or remedies that cannot be excluded or limited under applicable consumer law.
    """
}
