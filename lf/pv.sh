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
    if is_command tiv; then
        if is_command convert; then
            local temp_file="$(mktemp)"
            convert "${file}[0]" -sample 960x540\> "$temp_file"
            tiv -h $((height / 2)) -w "$width" "$temp_file"
            rm "$temp_file"
        else
            tiv -h $((height / 2)) -w "$width" "$file"
        fi
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

