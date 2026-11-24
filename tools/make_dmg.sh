#!/bin/zsh
# Packages build/SuperMac.app into dist/SuperMac-<version>.dmg
set -e
cd "$(dirname "$0")/.."
VER=$(defaults read "$PWD/build/SuperMac.app/Contents/Info.plist" CFBundleShortVersionString)
NAME="SuperMac-$VER-beta"
STAGE=$(mktemp -d)/Super\ Mac
mkdir -p "$STAGE" dist
cp -R build/SuperMac.app "$STAGE/Super Mac.app"
ln -s /Applications "$STAGE/Applications"
cp "dist_assets/How to install.txt" "$STAGE/"
rm -f "dist/$NAME.dmg"
hdiutil create -volname "Super Mac" -srcfolder "$STAGE" -fs HFS+ -format UDZO -imagekey zlib-level=9 "dist/$NAME.dmg" >/dev/null
hdiutil verify "dist/$NAME.dmg" >/dev/null && echo "dist/$NAME.dmg"
