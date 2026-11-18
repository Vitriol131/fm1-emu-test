#!/usr/bin/env bash
# Zip the plugin `UNIVERSAL=1 tools/build_plugin.sh` built (target/plugin) for a release:
# target/plugin/release/fm1-plugin-<version>-macos-universal.zip with the AU, the VST3, the CLAP and
# an install guide, and the release's notes beside it (notes.md). With APPLE_ID, APPLE_TEAM_ID
# and APPLE_APP_PASSWORD set (and the bundles signed with a Developer ID), Apple notarizes it and
# the tickets are stapled to the bundles, so it installs without warnings; otherwise the guide
# says how to let macOS open an unsigned plugin.
#   tools/package_plugin.sh
set -euo pipefail
cd "$(dirname "$0")/.."
out=target/plugin
version=$(sed -nE 's/^version = "(.*)"/\1/p' crates/fm1-plugin/Cargo.toml | head -1)
name=fm1-plugin-$version-macos-universal
rel=$out/release
rm -rf "$rel"
mkdir -p "$rel/$name"
for b in FM-1-MIDI-Learn-Fork.component FM-1-MIDI-Learn-Fork.vst3 FM-1-MIDI-Learn-Fork.clap; do
  executable=FM-1-MIDI-Learn-Fork
  [ "$b" = "FM-1-MIDI-Learn-Fork.clap" ] && executable=FM-1
  lipo "$out/$b/Contents/MacOS/$executable" -verify_arch arm64 x86_64 ||
    { echo "$out/$b: missing or not universal; run UNIVERSAL=1 tools/build_plugin.sh first" >&2; exit 1; }
  # every bundle says the release's version (0.5.1's AU and VST3 said 0.1.0, the wrapper's own)
  v=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$out/$b/Contents/Info.plist")
  [ "$v" = "$version" ] || { echo "$out/$b is version $v, not $version: rebuild (UNIVERSAL=1 tools/build_plugin.sh)" >&2; exit 1; }
done
# the AU's component version, what hosts compare to decide whether to scan it again: 0xMMmmpp
IFS=. read -r ma mi pa <<<"$version"
auv=$(/usr/libexec/PlistBuddy -c 'Print :AudioComponents:0:version' "$out/FM-1-MIDI-Learn-Fork.component/Contents/Info.plist")
[ "$auv" = $(( (ma << 16) | (mi << 8) | pa )) ] || { echo "the AU's component version is $auv, not $version's" >&2; exit 1; }

notarized=
if [ -n "${APPLE_ID:-}" ] && [ -n "${APPLE_TEAM_ID:-}" ] && [ -n "${APPLE_APP_PASSWORD:-}" ]; then
  ditto -c -k --keepParent "$out/FM-1-MIDI-Learn-Fork.component" "$rel/n-au.zip"
  ditto -c -k --keepParent "$out/FM-1-MIDI-Learn-Fork.vst3" "$rel/n-vst3.zip"
  ditto -c -k --keepParent "$out/FM-1-MIDI-Learn-Fork.clap" "$rel/n-clap.zip"
  for z in "$rel"/n-*.zip; do
    xcrun notarytool submit "$z" --apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" --password "$APPLE_APP_PASSWORD" --wait
  done
  for b in FM-1-MIDI-Learn-Fork.component FM-1-MIDI-Learn-Fork.vst3 FM-1-MIDI-Learn-Fork.clap; do xcrun stapler staple "$out/$b"; done
  rm -f "$rel"/n-*.zip
  notarized=1
fi

for b in FM-1-MIDI-Learn-Fork.component FM-1-MIDI-Learn-Fork.vst3 FM-1-MIDI-Learn-Fork.clap; do ditto "$out/$b" "$rel/$name/$b"; done

if [ -n "$notarized" ]; then
  unblock="It's signed and notarized by Apple, so macOS opens it without asking."
else
  unblock='This build is not signed with an Apple Developer ID, so macOS blocks it until you allow it.
After copying, run this once in Terminal:

    xattr -dr com.apple.quarantine ~/Library/Audio/Plug-Ins/Components/FM-1-MIDI-Learn-Fork.component ~/Library/Audio/Plug-Ins/VST3/FM-1-MIDI-Learn-Fork.vst3 ~/Library/Audio/Plug-Ins/CLAP/FM-1-MIDI-Learn-Fork.clap'
fi

cat > "$rel/$name/INSTALL.txt" <<TXT
FM-1 MIDI Learn Fork $version: unofficial Vitriol131 fork (AU, VST3, CLAP)
https://github.com/joakimeriksson/fm1-emu

For Macs with Apple silicon or Intel, macOS 11 or later.

1. Copy the plug-ins to your plug-in folders (create the folders that are missing):
     FM-1-MIDI-Learn-Fork.component  ->  ~/Library/Audio/Plug-Ins/Components/   (AU: Logic, GarageBand)
     FM-1-MIDI-Learn-Fork.vst3       ->  ~/Library/Audio/Plug-Ins/VST3/         (Ableton, Cubase, Reaper, ...)
     FM-1-MIDI-Learn-Fork.clap       ->  ~/Library/Audio/Plug-Ins/CLAP/         (Bitwig, Reaper, ...)
   In Finder: Go > Go to Folder... and paste ~/Library/Audio/Plug-Ins
2. $unblock
3. Restart your DAW. Add "FM-1 MIDI Learn Fork" (by Vitriol131 Community Fork) as an instrument on a track.
   GarageBand: tick Settings > Audio/MIDI > Enable Audio Units first.
4. In the plug-in's window, click "Load firmware..." and pick a .fwsc package: a community
   firmware (the list, with each author's link: https://joakimeriksson.github.io/fm1-emu/)
   or M-VAVE's own. Play it from MIDI or with the mouse on its panel.

The firmware and the patches it saves are kept in your project.
TXT

(cd "$rel" && ditto -c -k --keepParent "$name" "$name.zip")
rm -rf "$rel/$name"

cat > "$rel/notes.md" <<MD
**FM-1 MIDI Learn Fork** is an unofficial, AI-assisted / vibe-coded fork of the M-VAVE FM-1 emulator.
It adds a distinct plugin identity and an experimental MIDI Learn layer. Use at your own risk;
no warranty is provided.

- **Load firmware…** loads any \`.fwsc\`: the community firmwares
  ([the list](https://joakimeriksson.github.io/fm1-emu/)) or M-VAVE's own. An SMK-37 package
  gets the SMK-37's panel.
- Enable MIDI Learn, click a panel control, then move a MIDI CC or press a MIDI note.
- The intended Learn targets include FM-1 encoders, Master, buttons and selectors; SMK-37 encoders,
  pads, faders, wheels, buttons and selectors. The SMK-37's 37 musical keys are excluded.
- Learned assignments are saved in the DAW project and displayed in the plugin's assignments list.
- MIDI Learn is experimental: a physical controller and Ableton Live 12 test is still required.
- The project keeps the firmware and the patches it saves.
- The emulator's lead over the DAW is reported as latency, so notes land where they were placed.

**Download:** \`$name.zip\`, for Macs with Apple silicon or Intel (macOS 11 or later). Its \`INSTALL.txt\`
says where each file goes.$( [ -n "$notarized" ] && echo " Signed and notarized." || printf '\n\nThis build is **not signed** with an Apple Developer ID, so macOS blocks it until it is\nallowed. After copying the plug-ins, run once in Terminal:\n\n```sh\nxattr -dr com.apple.quarantine ~/Library/Audio/Plug-Ins/Components/FM-1-MIDI-Learn-Fork.component ~/Library/Audio/Plug-Ins/VST3/FM-1-MIDI-Learn-Fork.vst3 ~/Library/Audio/Plug-Ins/CLAP/FM-1-MIDI-Learn-Fork.clap\n```' )

The original upstream project's validation results do not validate this fork. This fork's current
source changes still require a fresh build, AU/VST3 validation and hands-on DAW/controller testing.
Report issues at https://github.com/Vitriol131/fm1-emu-test/issues.

MIT licensed, like everything it builds with (nih-plug, clap-wrapper, the CLAP, AudioUnit and
VST3 SDKs). The firmwares are their authors'.
MD
echo "packaged $rel/$name.zip ($( [ -n "$notarized" ] && echo notarized || echo unsigned ))"
