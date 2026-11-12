#!/bin/bash
# Fetch the dependency sources at the exact revisions recorded by upstream
# SwitchWave. Submodules are intentionally not checked into this repository so
# that a plain source checkout stays small; CI calls this script before build.
set -euo pipefail

cd "$(dirname "$0")/.."

FFMPEG_SHA="${FFMPEG_SHA:-caeec83b791be08ed43468a2ef426d6901d51c78}"
MPV_SHA="${MPV_SHA:-67c2e3f28be29a380a7eccdfdf59694bcd3ad417}"
LIBUAM_SHA="${LIBUAM_SHA:-f8c9eef01ffe06334d530393d636d69e2b52744b}"
IMGUI_SHA="${IMGUI_SHA:-1dfbb100d6ca6e7d813102e979c07f66a56546bb}"
IMPLOT_SHA="${IMPLOT_SHA:-18c72431f8265e2b0b5378a3a73d8a883b2175ff}"
INIH_SHA="${INIH_SHA:-cd5f93974067a143434b0e9a1c1a8ae906af599b}"

fetch_pin() {
    local url="$1" sha="$2" dir="$3"

    if [ -d "$dir/.git" ] && git -C "$dir" cat-file -e "$sha^{commit}" 2>/dev/null; then
        git -C "$dir" checkout -q --detach "$sha"
        return
    fi

    rm -rf "$dir"
    mkdir -p "$dir"
    git -C "$dir" init -q
    git -C "$dir" remote add origin "$url"
    git -C "$dir" fetch -q --depth 1 origin "$sha"
    git -C "$dir" checkout -q --detach FETCH_HEAD
}

fetch_pin https://github.com/averne/FFmpeg.git          "$FFMPEG_SHA"  ffmpeg
fetch_pin https://github.com/averne/mpv.git             "$MPV_SHA"     mpv
fetch_pin https://github.com/averne/libuam.git          "$LIBUAM_SHA"  libuam
fetch_pin https://github.com/ocornut/imgui.git          "$IMGUI_SHA"   src/imgui
fetch_pin https://github.com/epezent/implot.git         "$IMPLOT_SHA"  src/implot
fetch_pin https://github.com/benhoyt/inih.git           "$INIH_SHA"    src/inih

for dir in ffmpeg mpv libuam src/imgui src/implot src/inih; do
    printf '%-12s %s\n' "$dir" "$(git -C "$dir" rev-parse --short=10 HEAD)"
done
