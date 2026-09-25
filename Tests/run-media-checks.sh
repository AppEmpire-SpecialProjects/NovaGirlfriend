#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Caller supplies one owned scratch root; this script does not delete user files.
: "${1:?Supply an owned scratch directory}"
swiftc -parse-as-library -DDEBUG \
  Tests/PremiumStoreStub.swift \
  NovaGirlfriend/Services/AccessPolicy.swift \
  NovaGirlfriend/Models/ConversationModels.swift \
  NovaGirlfriend/Models/CharacterProfile.swift \
  NovaGirlfriend/Models/Personality.swift \
  NovaGirlfriend/Models/Scenario.swift \
  NovaGirlfriend/Models/VoiceProfile.swift \
  NovaGirlfriend/Services/ServiceProtocols.swift \
  NovaGirlfriend/Services/AI/EndpointVault.swift \
  NovaGirlfriend/Services/AI/TOTPTokenProvider.swift \
  NovaGirlfriend/Services/AI/MediaGenerationClient.swift \
  NovaGirlfriend/Services/AI/TextChunker.swift \
  NovaGirlfriend/Services/Speech/TranscriptionController.swift \
  NovaGirlfriend/Services/Speech/RemoteVoiceSpeechService.swift \
  Tests/TranscriptionStubs.swift \
  Tests/MediaDomainChecks.swift -o "$1/media-domain-checks"
"$1/media-domain-checks"
