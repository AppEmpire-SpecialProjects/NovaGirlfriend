#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Caller supplies one owned scratch root; this script does not delete user files.
: "${1:?Supply an owned scratch directory}"
swiftc -parse-as-library \
  NovaGirlfriend/Models/ConversationModels.swift \
  NovaGirlfriend/Models/CharacterProfile.swift \
  NovaGirlfriend/Models/Personality.swift \
  NovaGirlfriend/Models/Scenario.swift \
  NovaGirlfriend/Models/VoiceProfile.swift \
  NovaGirlfriend/Persistence/ConversationRecord.swift \
  NovaGirlfriend/Repositories/ProductContentRepository.swift \
  NovaGirlfriend/Repositories/ConversationRepository.swift \
  NovaGirlfriend/Services/ServiceProtocols.swift \
  NovaGirlfriend/Services/AppConfiguration.swift \
  NovaGirlfriend/Services/AIService.swift \
  NovaGirlfriend/Services/AI/AICredentialStore.swift \
  NovaGirlfriend/Services/ExportService.swift \
  NovaGirlfriend/Services/Persistence/ConversationSupport.swift \
  NovaGirlfriend/ViewModels/ChatViewModel.swift \
  Tests/ChatDomainChecks.swift -o "$1/chat-domain-checks"
"$1/chat-domain-checks" "$1/chat-checks-$(uuidgen).store"
