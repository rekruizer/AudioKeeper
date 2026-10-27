#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
TEST_BUILD=$(mktemp -d)
trap 'rm -rf "$TEST_BUILD"' EXIT

SOURCES=()
while IFS= read -r source; do
    SOURCES+=("$source")
done < <(find Sources -name '*.swift' ! -name 'AudioKeeperApp.swift' | sort)

# Match Xcode's actor isolation and check compatibility back to macOS 13.
swiftc -warnings-as-errors -swift-version 6 -default-isolation MainActor \
    -enable-upcoming-feature NonisolatedNonsendingByDefault \
    -enable-upcoming-feature MemberImportVisibility \
    -enable-upcoming-feature InferIsolatedConformances \
    -target "$(uname -m)-apple-macosx13.0" \
    -module-cache-path "${TMPDIR:-/tmp}/AudioKeeper-module-cache" \
    -parse-as-library "${SOURCES[@]}" Tests/RegressionTests.swift \
    -o "$TEST_BUILD/RegressionTests"
"$TEST_BUILD/RegressionTests"

python3 Tests/PackagingTests.py
