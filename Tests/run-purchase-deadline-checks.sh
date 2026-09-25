#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${1:?Supply an owned scratch directory}"
for optimization in Onone O; do
  swiftc -swift-version 6 -"$optimization" -parse-as-library \
    NovaGirlfriend/Services/PurchaseDeadline.swift \
    Tests/PurchaseDeadlineChecks.swift -o "$1/purchase-deadline-checks-$optimization"
  "$1/purchase-deadline-checks-$optimization"
done
