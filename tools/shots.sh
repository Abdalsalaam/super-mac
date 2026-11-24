#!/bin/zsh
# Captures screenshots of every screen into ./shots (run ./build.sh first)
set -e
cd "$(dirname "$0")/.."
W=$(mktemp -d)
cp Sources/*.swift "$W/" && sed -i '' 's/^@main$//' "$W/App.swift"
SDK=$(ls -d /Library/Developer/CommandLineTools/SDKs/MacOSX26*.sdk 2>/dev/null | sort -V | tail -1)
swiftc -parse-as-library -swift-version 5 -sdk "$SDK" -target arm64-apple-macos13.0 "$W"/*.swift tools/snap_v09.swift -o "$W/snap"
mkdir -p shots
"$W/snap" "$PWD/shots" "$PWD/build/SuperMac.app/Contents/Resources" "${1:-all}"
