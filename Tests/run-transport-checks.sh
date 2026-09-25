#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${1:?Supply an owned scratch directory}"
mkdir -p "$1/Transport.bundle"
cat > "$1/Transport.bundle/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>local.nova.transport-checks</string>
<key>NovaAIBaseURL</key><string>https://transport.invalid</string>
</dict></plist>
PLIST
swiftc -parse-as-library -DDEBUG \
  Tests/PremiumStoreStub.swift \
  NovaGirlfriend/Services/AccessPolicy.swift \
  NovaGirlfriend/Services/AI/EndpointVault.swift \
  NovaGirlfriend/Services/AI/TOTPTokenProvider.swift \
  NovaGirlfriend/Models/ConversationModels.swift \
  NovaGirlfriend/Models/CharacterProfile.swift \
  NovaGirlfriend/Models/Personality.swift \
  NovaGirlfriend/Models/Scenario.swift \
  NovaGirlfriend/Models/VoiceProfile.swift \
  NovaGirlfriend/Persistence/ConversationRecord.swift \
  NovaGirlfriend/Models/AffinityModels.swift \
  NovaGirlfriend/Models/AchievementModels.swift \
  NovaGirlfriend/Models/ConversationLanguage.swift \
  NovaGirlfriend/Persistence/AffinityRecord.swift \
  NovaGirlfriend/Persistence/AchievementRecords.swift \
  NovaGirlfriend/Persistence/MemoryFactRecord.swift \
  NovaGirlfriend/Services/Progress/AffinityService.swift \
  NovaGirlfriend/Services/Progress/AchievementService.swift \
  NovaGirlfriend/Services/AI/MemoryExtractor.swift \
  NovaGirlfriend/Services/Content/GreetingComposer.swift \
  NovaGirlfriend/Services/Content/ChatPhotoStore.swift \
  NovaGirlfriend/Repositories/ProductContentRepository.swift \
  NovaGirlfriend/Repositories/ConversationRepository.swift \
  NovaGirlfriend/Services/ServiceProtocols.swift \
  NovaGirlfriend/Services/AppConfiguration.swift \
  NovaGirlfriend/Services/AIService.swift \
  NovaGirlfriend/Services/ExportService.swift \
  NovaGirlfriend/Services/Persistence/ConversationSupport.swift \
  NovaGirlfriend/ViewModels/ChatViewModel.swift \
  Tests/AITransportChecks.swift -o "$1/ai-transport-checks"
"$1/ai-transport-checks" "$1/Transport.bundle"
