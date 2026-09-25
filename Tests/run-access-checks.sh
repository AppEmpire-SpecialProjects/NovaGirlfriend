#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${1:?Supply an owned scratch directory}"
swiftc -parse-as-library \
  Tests/PremiumStoreStub.swift \
  NovaGirlfriend/Services/AccessPolicy.swift \
  Tests/AccessPolicyChecks.swift -o "$1/access-policy-checks"
"$1/access-policy-checks"
