# TMNT on iOS

Both games for iPhone and iPad (iOS 15 or later, arm64), built on the same SDL2 window port as the other platforms:

- **TMNT**: the console version (arcade, Splinter Way, options).
- **TMNT Arcade**: the arcade game as it is, with a COIN button.

No game data is in the app. Like the other devices, the game takes its assets from a pack (`tmnt.assets`) made from
**your own ROM set** (MAME's `tmnt`, World 4 Players). An app with your pack in it is yours alone: never share it.

## Install a release IPA

The release's IPAs are unsigned and have no pack. You add your pack, then sign them as you install them.

1. **Make your pack.** Download the game for your computer from the
   [releases](https://github.com/cheviman/tmnt-port/releases), put `tmnt.zip` (your ROM set) beside it, and run it
   once with `--write-pack`:
   ```sh
   # macOS (the zip beside the .app)
   "TMNT.app/Contents/MacOS/TMNT" --write-pack tmnt.assets
   # Windows
   TMNT.exe --write-pack tmnt.assets
   ```
2. **Put the pack in the IPA** with [add_pack.sh](add_pack.sh) (macOS or Linux; or unzip the IPA, copy `tmnt.assets` into
   `Payload/TMNT.app/` beside `Info.plist`, and zip `Payload` again):
   ```sh
   ports/ios/add_pack.sh TMNT-1.0.5-ios.ipa tmnt.assets
   ```
   It writes `TMNT-1.0.5-ios-with-assets.ipa`.
3. **Sideload it**, which signs it with your own Apple ID: AltStore, SideStore, Sideloadly, or Xcode's Devices and
   Simulators window. A free Apple ID's apps last 7 days; a paid developer account's a year.

## Controls

The screen is landscape. A stick where your left thumb lands, **ATTACK**, **JUMP**, **SPECIAL** (the two together:
the special attack) and **START** (COIN in TMNT Arcade) on the right. On a tall screen (an iPad, an open iPhone Duo)
the picture goes to the top and the controls under it. Game controllers work too (MFi, DualShock, DualSense, Xbox):
each one is a player, up to four, and they hide the touch controls. TMNT's OPTIONS has video and volume.

## Build it yourself

Xcode with the iOS SDK, CMake 3.20 or later, and `git` (SDL2 is fetched and patched for the UIScene lifecycle which apps
linked against the iOS 27 SDK need: [sdl2-uiscene.patch](sdl2-uiscene.patch)).

```sh
cmake -S . -B build/ios -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=iphonesimulator \
      -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0 -DTMNT_REFERENCE_TOOLS=OFF \
      -DTMNT_BIN_DIR=build/ios/bin
cmake --build build/ios --config Release --target tmnt_console tmnt
```

- With `tmnt.assets` at `build/bin/tmnt.assets` (or `-DTMNT_IOS_PACK=path`) the apps carry it.
- For a device: `-DCMAKE_OSX_SYSROOT=iphoneos -DTMNT_IOS_TEAM=<your team ID> -DTMNT_IOS_BUNDLE_PREFIX=<your prefix>`
  and `-- -allowProvisioningUpdates` on the build.
- A release (no pack, unsigned): `-DTMNT_IOS_NO_PACK=ON`, and `-- CODE_SIGNING_ALLOWED=NO` on the build.
