#!/bin/zsh
# Builds SuperMac.app into ./build
set -e
cd "$(dirname "$0")"
APP=build/SuperMac.app
ART=art
rm -rf build && mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" build/AppIcon.iconset

# The newest SDK's SwiftUI needs Xcode's macro plugins; the macOS 26 SDK works with Command Line Tools alone.
SDK=$(ls -d /Library/Developer/CommandLineTools/SDKs/MacOSX26*.sdk 2>/dev/null | sort -V | tail -1)
# Universal binary: Apple Silicon + Intel
for arch in arm64 x86_64; do
  swiftc -O -parse-as-library -swift-version 5 -sdk "$SDK" -target $arch-apple-macos13.0 \
    Sources/*.swift -o build/SuperMac-$arch
done
lipo -create build/SuperMac-arm64 build/SuperMac-x86_64 -output "$APP/Contents/MacOS/SuperMac"

# Illustrations (downscaled to 512px to keep the app small)
for n in smart_care cleanup protection performance applications clutter space_lens automation settings; do
  sips -Z 512 "$ART/$n.png" --out "$APP/Contents/Resources/$n.png" >/dev/null
done

# About page: developer photo + white brand glyphs
sips -Z 400 assets/developer.jpg --out "$APP/Contents/Resources/developer.png" -s format png >/dev/null
swiftc -O -sdk "$SDK" tools/brand_png.swift -o build/brand_png
for b in facebook instagram linkedin github; do
  build/brand_png assets/brands/$b.svg "$APP/Contents/Resources/brand_$b.png"
done

# App icon
swift make_icon.swift "$ART/logo_a.png" build/icon_1024.png
sips -Z 512 build/icon_1024.png --out "$APP/Contents/Resources/app_icon.png" >/dev/null
for s in 16 32 128 256 512; do
  sips -z $s $s build/icon_1024.png --out build/AppIcon.iconset/icon_${s}x${s}.png >/dev/null
  sips -z $((s*2)) $((s*2)) build/icon_1024.png --out build/AppIcon.iconset/icon_${s}x${s}@2x.png >/dev/null
done
iconutil -c icns build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Super Mac</string>
  <key>CFBundleDisplayName</key><string>Super Mac</string>
  <key>CFBundleIdentifier</key><string>app.supermac.mac</string>
  <key>CFBundleExecutable</key><string>SuperMac</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.9</string>
  <key>CFBundleVersion</key><string>9</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSAppleEventsUsageDescription</key><string>Super Mac asks macOS for your administrator password to run maintenance tasks.</string>
</dict></plist>
EOF

codesign --force --deep -s - "$APP"
echo "Built $APP"
