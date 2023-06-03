#!/bin/sh
set -e

# (1) current file name
# (2) width
# (3) height
# (4) horizontal position
# (5) vertical position of preview pane
file="$1"
width="$2"
height="$3"
h_pos="$4"
v_pos="$5"

mime_type=$(file --mime-type --brief --dereference $1)
file_type=${mime_type%/*}

is_command() {
    command -v "$1" > /dev/null
}

print_mediainfo() {
    echo ""
    if is_command mediainfo; then
        mediainfo "$file" | tail --lines=+3
    else
        file --brief "$file"
    fi
}

case "$file_type" in
    image)
        if is_command tiv; then
            tiv -h $((height / 2)) -w "$width" "$file"
        fi
        print_mediainfo
        ;;
    video)
        print_mediainfo
        ;;
    *)
        LESSQUIET=1 less --RAW-CONTROL-CHARS -+--quit-if-one-screen "$file"
        ;;
esac

