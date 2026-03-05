#!/usr/bin/env bash
##################################################################################
# Copyright (c) 2026 Jahan Addison
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIEDi
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##################################################################################

set -euo pipefail

BLUE=$'\033[1;34m'
RED=$'\033[0;31m'
RESET=$'\033[0m'

die() {
  echo "${RED}error: $*${RESET}" >&2; exit 1;
}

info() {
  echo "${BLUE}>> $*${RESET}"
}

detail() {
  echo "$*"
}

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
VMS_SRC="$REPO_ROOT/external/vms"
VMS_BUILD="$VMS_SRC/build"
GAME_BUILD="$REPO_ROOT/build"
VMS_BIN="$VMS_BUILD/vms"
GAME_ROM="$GAME_BUILD/serpent.vms"

check() {
  command -v "$1" &>/dev/null || die "'$1' not found — $2";
}

git submodule update --init

# platform detection

case "$OSTYPE" in
  darwin*)  PLATFORM=mac   ;;
  linux*)   PLATFORM=linux ;;
  msys*|cygwin*|mingw*) PLATFORM=windows ;;
  *)        die "unsupported platform: $OSTYPE" ;;
esac

# platform-specific installation

if [[ "$PLATFORM" == mac ]]; then
  check cmake "install via: brew install cmake"
  check brew  "install Homebrew from https://brew.sh"

  if ! command -v xquartz &>/dev/null && ! [[ -d /Applications/Utilities/XQuartz.app ]]; then
    detail "XQuartz not found — installing via Homebrew Cask (this may take a moment)..."
    brew install --cask xquartz
    detail ""
    detail "XQuartz installed. You may need to log out and back in once for the"
    detail "DISPLAY launch agent to register, then re-run this script."
    exit 0
  fi

  # Ensure XQuartz is running and DISPLAY is set
  if ! pgrep -x Xquartz &>/dev/null; then
    open -a XQuartz
    sleep 3
  fi
  export DISPLAY="${DISPLAY:-:0}"

elif [[ "$PLATFORM" == linux ]]; then
  check cmake "install via your package manager (apt/dnf/pacman)"
  check cc    "install gcc or clang"

  # Check for X11 headers; offer the right install hint per distro
  if ! [[ -f /usr/include/X11/Xlib.h ]]; then
    if command -v apt &>/dev/null; then
      die "X11 headers missing — run: sudo apt install libx11-dev"
    elif command -v dnf &>/dev/null; then
      die "X11 headers missing — run: sudo dnf install libX11-devel"
    elif command -v pacman &>/dev/null; then
      die "X11 headers missing — run: sudo pacman -S libx11"
    else
      die "X11 headers missing — install libx11-dev for your distro"
    fi
  fi

  export DISPLAY="${DISPLAY:-:0}"

elif [[ "$PLATFORM" == windows ]]; then
  check cmake "install via MSYS2: pacman -S mingw-w64-x86_64-cmake"
  check cc    "install via MSYS2: pacman -S mingw-w64-x86_64-gcc"

  # Check X11 headers (MSYS2 mingw64 package: mingw-w64-x86_64-libx11)
  X11_HDR=""
  for p in /mingw64/include/X11/Xlib.h /ucrt64/include/X11/Xlib.h; do
    [[ -f "$p" ]] && X11_HDR="$p" && break
  done
  if [[ -z "$X11_HDR" ]]; then
    die "X11 headers missing — run: pacman -S mingw-w64-x86_64-libx11"
  fi

  # Expect an X server (VcXsrv / GWSL / Xming) to be running
  export DISPLAY="${DISPLAY:-:0}"
  detail "Windows: ensure an X server (VcXsrv, GWSL, or Xming) is running on display $DISPLAY"
fi

# build emulator

if [[ ! -x "$VMS_BIN" ]]; then
  info "building softvms emulator ..."
  cmake -B "$VMS_BUILD" -S "$VMS_SRC"
  cmake --build "$VMS_BUILD" --parallel
else
  info "softvms already built (--rebuild to force)"
fi

# build game

if [[ ! -f "$GAME_ROM" ]]; then
  info "building serpent"
  cmake -B "$GAME_BUILD" -S "$REPO_ROOT"
  cmake --build "$GAME_BUILD" --parallel
else
  info "serpent already built (--rebuild to force)"
fi

# optional --rebuild flag

if [[ "${1:-}" == "--rebuild" ]]; then
  info "rebuilding both targets ..."
  cmake --build "$VMS_BUILD" --parallel
  cmake --build "$GAME_BUILD" --parallel
fi

# let's play!

info "Launching: $VMS_BIN $GAME_ROM ..."
"$VMS_BIN" "$GAME_ROM"
