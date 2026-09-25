#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Caller supplies one owned scratch root; this script does not delete user files.
: "${1:?Supply an owned scratch directory}"
swiftc -parse-as-library \
  Tests/PremiumStoreStub.swift \
  NovaGirlfriend/Services/AccessPolicy.swift \
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
  NovaGirlfriend/Services/AI/EndpointVault.swift \
  NovaGirlfriend/Services/AI/TOTPTokenProvider.swift \
  NovaGirlfriend/Services/AI/AICredentialStore.swift \
  NovaGirlfriend/Services/ExportService.swift \
  NovaGirlfriend/Services/Persistence/ConversationSupport.swift \
  NovaGirlfriend/ViewModels/ChatViewModel.swift \
  NovaGirlfriend/Persistence/CharacterRecord.swift \
  NovaGirlfriend/Repositories/CharacterRepository.swift \
  NovaGirlfriend/Repositories/FavoriteCharacterStore.swift \
  NovaGirlfriend/Persistence/MediaRecords.swift \
  NovaGirlfriend/Models/GalleryModels.swift \
  Tests/AccessIntegrationChecks.swift \
  Tests/ChatDomainChecks.swift -o "$1/chat-domain-checks"
"$1/chat-domain-checks" "$1/chat-checks-$(uuidgen).store"
