# Building Nova

Nova requires **iOS 17.0 or later** because persistence uses Apple's SwiftData framework. An iOS 16 deployment claim would be incorrect; supporting iOS 16 requires replacing that persistence layer.

Open `NovaGirlfriend.xcodeproj`, select the shared `NovaGirlfriend` scheme and an iPhone simulator. This project was integrated with Xcode 26.2 and iOS 18.6 on iPhone 16. All app sources under `NovaGirlfriend/` belong to the file-system-synchronized app target. Native UI tests are in `Tests/UI/` and run using Product → Test.

Build settings `NOVA_AI_BASE_URL`, `APP_STORE_ID` and `SUPPORT_EMAIL` are intentionally empty. Configure real production values before distribution. The generated Info.plist exposes these as `NovaAIBaseURL`, `APP_STORE_ID` and `SUPPORT_EMAIL`. AI requires an HTTPS service implementing `POST /v1/completions`; credentials are entered in AI Connection and stored in Keychain, never bundled. Until configured, sending persists the user's message as failed and displays the actual configuration error with Retry. No AI response is fabricated. App Store/support links are hidden unless valid configured destinations exist.

Microphone and Speech permissions are requested on use. Photo selection uses the system PhotosPicker. Gallery Share exports the actual image through the native share sheet. Each built-in companion has an included portrait and an original illustration unlocked after five persisted, completed text exchanges. Saves and unlock dates are stored locally; failed, pending, voice-only and preview activity do not advance Gallery progress. No generated-media provider is configured. Simulator execution cannot establish real microphone quality, audible TTS, or speech-recognition availability; verify those on a physical device before release.

The icon is original gradient/orbit/star artwork. Built-in characters use bundled, AI-generated fictional portrait illustrations in `Assets.xcassets`, rendered through `Components/CharacterArtwork.swift`; scenario and mood artwork remains procedural SwiftUI illustration. Included gallery portraits reuse the bundled illustrations, not user gallery items. Custom uploaded images remain local and take priority over bundled portraits.

Repeatable domain checks: `bash Tests/run-chat-checks.sh <owned-temporary-directory>`. UI test screenshots are kept as xcresult attachments. Integration evidence is preserved in `Evidence/Integration/`.
