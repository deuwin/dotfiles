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

mime_type=$(file --mime-type --brief --dereference "$file")
file_type=${mime_type%/*}

is_command() {
    command -v "$1" > /dev/null
}

draw_image() {
    if is_command chafa; then
        chafa --size=${width}x$((height/2)) --animate=false "$file"
        echo ""
    fi
}

print_info() {
    if is_command mediainfo; then
        mediainfo "$file" | tail --lines=+3
    else
        file --brief "$file"
    fi
}

case "$file_type" in
    image)
        draw_image
        print_info
        ;;
    video)
        print_info
        ;;
    *)
        LESSQUIET=1 less --RAW-CONTROL-CHARS -+--quit-if-one-screen "$file"
        ;;
esac

