#!/bin/sh
# Name:        add_pack.sh
# Description: puts the player's own assets pack (tmnt.assets) into a TMNT IPA of the release, which has none
# Usage:       ports/ios/add_pack.sh TMNT.ipa tmnt.assets [Output.ipa]
# The pack is made from your own ROM set (MAME's tmnt, World 4 Players): see ports/ios/README.md. An IPA with a
# pack in it is yours alone: never share it. Its signature is the release's (none): sign it again when you
# install it (AltStore, SideStore, Sideloadly, or Xcode's Devices window).
set -eu

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
	echo "Usage: $0 TMNT.ipa tmnt.assets [Output.ipa]" >&2
	exit 2
fi
ipa=$1
pack=$2
out=${3:-"${ipa%.ipa}-with-assets.ipa"}
[ -f "$ipa" ] || { echo "No IPA at $ipa" >&2; exit 1; }
[ -f "$pack" ] || { echo "No assets pack at $pack" >&2; exit 1; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
unzip -q "$ipa" -d "$work"
app=$(find "$work/Payload" -maxdepth 1 -name '*.app' | head -1)
[ -n "$app" ] || { echo "$ipa has no app in it" >&2; exit 1; }
cp "$pack" "$app/tmnt.assets"
rm -rf "$app/_CodeSignature"    # (it signed what the app was without the pack)
out_dir=$(cd "$(dirname "$out")" && pwd)
rm -f "$out_dir/$(basename "$out")"
(cd "$work" && zip -qry "$out_dir/$(basename "$out")" Payload)
echo "Wrote $out: sign it again to install it, and never share it (it has your game's data)"
