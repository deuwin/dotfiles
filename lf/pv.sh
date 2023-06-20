#!/usr/bin/env sh
set -e

$ZDOTDIR/scripts/print_mediainfo.zsh "$1" "$2" "$3" "$4" "$5" && exit 0

LESSQUIET=1 less --RAW-CONTROL-CHARS -+--quit-if-one-screen "$1"

