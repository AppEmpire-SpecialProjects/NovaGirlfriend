#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Caller supplies one owned scratch root; never remove shared/user artifacts.
: "${1:?Supply an owned scratch directory}"
if [[ ! -d "$1" ]]; then
  printf 'Scratch directory does not exist: %s\n' "$1" >&2
  exit 2
fi
scratch_root="$(cd "$1" && pwd)"
prefix="$scratch_root/gallery-checks-$(uuidgen)"
printf 'Gallery check artifacts: %s\n' "$prefix"

common_sources=(
  NovaGirlfriend/Models/ConversationModels.swift
  NovaGirlfriend/Models/VoiceProfile.swift
  NovaGirlfriend/Persistence/ConversationRecord.swift
)

# Equal module and entity names exercise real lightweight migration, not a rename.
xcrun swiftc -parse-as-library -module-name GalleryCheckModels \
  "${common_sources[@]}" \
  Tests/GalleryLegacyMigrationSeed.swift \
  -o "$prefix-legacy-seed"
xcrun swiftc -parse-as-library -module-name GalleryCheckModels \
  "${common_sources[@]}" \
  NovaGirlfriend/Models/CharacterProfile.swift \
  NovaGirlfriend/Models/Personality.swift \
  NovaGirlfriend/Models/Scenario.swift \
  NovaGirlfriend/Models/GalleryModels.swift \
  NovaGirlfriend/Persistence/MediaRecords.swift \
  NovaGirlfriend/Repositories/ProductContentRepository.swift \
  NovaGirlfriend/Repositories/GalleryCatalog.swift \
  NovaGirlfriend/Repositories/GalleryActivity.swift \
  NovaGirlfriend/Repositories/GalleryRepository.swift \
  Tests/GalleryDomainChecks.swift \
  -o "$prefix-domain"
xcrun swiftc -parse-as-library \
  NovaGirlfriend/Views/Gallery/GalleryMotion.swift \
  Tests/GalleryMotionChecks.swift \
  -o "$prefix-motion"

# Run every independent group even on assertion failure, but preserve failing exit status.
result=0
run_check() {
  if "$@"; then
    return 0
  else
    local code=$?
    printf 'CHECK COMMAND FAILED (exit %s):' "$code" >&2
    printf ' %q' "$@" >&2
    printf '\n' >&2
    result=1
  fi
}
run_check "$prefix-domain" domain "$prefix"
run_check "$prefix-domain" restart-saved "$prefix"
run_check "$prefix-domain" restart-unsaved "$prefix"
run_check "$prefix-motion"
if "$prefix-legacy-seed" "$prefix-migration.store"; then
  run_check "$prefix-domain" migration "$prefix-migration.store"
else
  printf 'FAIL: migration seed command failed; migration not run\n' >&2
  result=1
fi
printf 'Gallery check suite exit status: %s\n' "$result"
exit "$result"
