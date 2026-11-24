<p align="center">
  <img src="art/logo_a.png" width="140" alt="Super Mac icon">
</p>

<h1 align="center">Super Mac</h1>

<p align="center">
  <b>A free, private Mac cleaner with a dark Liquid Glass UI.</b><br>
  Cleanup · Protection · Performance · Uninstaller · Clutter finder · Space Lens · Autopilot
</p>

<p align="center">
  <a href="https://github.com/amirmhmdart/super-mac/releases/latest"><img src="https://img.shields.io/github/v/release/amirmhmdart/super-mac?include_prereleases&label=download&color=8B5CF6" alt="Download"></a>
  <img src="https://img.shields.io/badge/macOS-14%2B-111?logo=apple" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Apple%20Silicon%20%26%20Intel-universal-EC4899" alt="Universal">
  <img src="https://img.shields.io/badge/price-free-10B981" alt="Free">
  <img src="https://img.shields.io/badge/license-MIT-3B82F6" alt="MIT">
</p>

<p align="center">
  <img src="docs/screenshots/idle_smartCare.jpg" width="880" alt="Super Mac — Smart Care">
</p>

---

## Download

**[⬇ Download Super Mac v0.9 beta (.dmg)](https://github.com/amirmhmdart/super-mac/releases/latest)**

1. Open the DMG and drag **Super Mac** to **Applications**.
2. Open it. The first time, macOS says it can't verify the developer (the app isn't from the App Store).
   Go to **System Settings → Privacy & Security** and click **Open Anyway**. You only do this once.

Requires macOS 14 Sonoma or newer. One universal app for Apple Silicon and Intel.

## What it does

| | |
|---|---|
| **Smart Care** | One scan checks junk, privacy, performance, apps and clutter together. One button fixes what's safe. |
| **Cleanup** | User caches, logs, temp files, saved app states, Xcode/npm junk, old iOS updates and the Trash. |
| **Protection** | Checks launch agents against known adware and clears browser history, cookies and recent-items lists. |
| **Performance** | Free up RAM, flush DNS, rebuild Spotlight and Quick Look, manage login items, spot memory-hungry apps. |
| **Applications** | Uninstall apps together with their support files, caches and preferences. Finds leftovers from apps you already deleted. |
| **My Clutter** | Large & old files, duplicate copies and forgotten installers in Downloads. |
| **Space Lens** | An interactive treemap of your disk. Click into folders to find what's huge. |
| **Autopilot** *(new)* | Scheduled scans (daily / weekly / monthly), optional automatic cleanup of safe junk, and smart alerts for low disk space, a full Trash, a big Downloads folder and memory pressure. Catches up after sleep. |
| **Mac Health** *(new)* | A live 0–100 score from disk, memory, junk, threats and Trash, with what's pulling it down. |
| **Command Palette** *(new)* | Press ⌘K, type, hit Return. Every action without leaving the keyboard. |
| **Disk Forecast** *(new)* | Learns how fast your disk fills and tells you roughly how many days you have left. |
| **History** *(new)* | Every cleanup is logged, with a 14-day chart and an all-time total. |
| **Ignore List** *(new)* | Folders Super Mac will never touch. |

<p align="center">
  <img src="docs/screenshots/smart_results.jpg" width="49%" alt="Smart Care results">
  <img src="docs/screenshots/settings_automation.jpg" width="49%" alt="Autopilot settings">
  <img src="docs/screenshots/lens_map.jpg" width="49%" alt="Space Lens">
  <img src="docs/screenshots/apps_results.jpg" width="49%" alt="Uninstaller">
  <img src="docs/screenshots/palette.jpg" width="49%" alt="Command Palette">
  <img src="docs/screenshots/settings_history.jpg" width="49%" alt="History and disk forecast">
  <img src="docs/screenshots/cleanup_results.jpg" width="49%" alt="Cleanup">
  <img src="docs/screenshots/about.jpg" width="49%" alt="About">
</p>

## Safe by design

- **Nothing leaves your Mac.** No account, no analytics, no ads. The only network call is the optional "Check for updates", which reads this repo's latest release.
- **Your files go to the Trash first.** Clutter, Applications and Space Lens never delete permanently, so you can always put things back.
- **Junk is deleted only inside known junk folders** (`~/Library/Caches`, `~/Library/Logs`, temp…). Apple's own caches and caches of running apps are skipped.
- **Autopilot only touches caches, logs, temp files and saved app states.** Never your documents, never the Trash.
- **Admin tasks use macOS's own password dialog.** Super Mac never sees your password.

Honest limits for this beta: Protection is an adware check, not a full antivirus. Safari data and the Trash need Full Disk Access. The app is signed ad-hoc and not notarized yet, hence the one-time "Open Anyway".

## Keyboard shortcuts

| Shortcut | Action |
|---|---|
| ⌘K | Command Palette |
| ⌘1 – ⌘7 | Jump to a module |
| ⌘8 | Autopilot |
| ⌘9 | History |
| ⌘, | Settings |

## Build from source

No Xcode project needed, just the Command Line Tools:

```bash
xcode-select --install          # once
./build.sh                      # builds build/SuperMac.app (universal)
./tools/make_dmg.sh             # packages dist/SuperMac-<version>-beta.dmg
./tools/shots.sh                # renders screenshots into shots/
```

```
Sources/
  App.swift            window, sidebar, menu bar extra, shortcuts
  Theme.swift          colors, Liquid Glass modifiers, buttons, animated background
  Components.swift     shared screens (landing, scanning, working, done)
  Screens.swift        every module's UI
  Models.swift         scanners and models for each module
  Prefs.swift          settings, history, Autopilot scheduler, notifications, update check
  SettingsAbout.swift  Settings and About pages
  Core.swift           file system, shell and live system stats helpers
art/                   3D glass illustrations
assets/                About page photo and brand glyphs
```

Built with SwiftUI. Liquid Glass on macOS 26, with a material fallback on macOS 14–15.

## Made by

<img src="assets/developer.jpg" width="96" align="left" style="border-radius:50%; margin-right:16px" alt="Amir Mohamed">

**Amir Mohamed**, designer & developer.
Ideas, bugs or just saying hi, all welcome.

[Facebook](https://www.facebook.com/AmirMohamedArtX/) · [Instagram](https://www.instagram.com/amirmhmdart/) · [LinkedIn](https://www.linkedin.com/in/amirmhmdart/) · [Email](mailto:amirmhmdart@gmail.com)

<br clear="left">

---

Released under the [MIT License](LICENSE). Not affiliated with Apple or MacPaw.
