#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# The app target must not contain provider-identifying plaintext: hosts,
# endpoint paths, or credentials. Tests and fixtures are development-only
# and intentionally out of scope.
pattern='llm''apps|fal\.media|llm_''totp|v1/chat/completions|text2''speech|speech2''text'
if grep -rInE "$pattern" NovaGirlfriend/; then
  echo "FAIL: plaintext provider markers found in NovaGirlfriend/"
  exit 1
else
  result=$?
  if [ "$result" -ne 1 ]; then
    echo "FAIL: provider marker scan could not complete" >&2
    exit "$result"
  fi
fi
echo "PASS: no plaintext provider markers in NovaGirlfriend/"
