#!/usr/bin/env zsh

# Takes the same inputs as an lf preview script
# https://pkg.go.dev/github.com/gokcehan/lf#hdr-Previewing_Files
# (1) current file name
# (2) width
# (3) height
# (4) horizontal position
# (5) vertical position of preview pane
file="$1"
width="$2"
height="$3"

if [[ -z $width ]]; then
    width=$COLS
    height=$LINES
fi

is_command() {
    command -v "$1" > /dev/null
}

print_info() {
    if is_command mediainfo > /dev/null; then
        # This output template inspired by
        # https://github.com/optio50/Mediainfo-Template
        local -a info=("${(@f)$(mediainfo \
            --Inform="file://$ZDOTDIR/scripts/mediainfo_output.txt" "$1")}")
        local line key_len key_max=0

        for line in ${(@)info}; do
            # skip blank values
            [[ $line == *: ]] && continue
            # max key length
            key_len=${#${line%%:*}}
            ((key_len > key_max)) && key_max=$key_len
        done

        local first_section=true key val
        for line in ${(@)info}; do
            if [[ $line == *:* ]]; then
                # Can't use zsh string splitting as some values will be blank
                val=${line#*:}
                [[ -z $val ]] && continue

                # Use basename of filename
                key=${line%%:*}
                if [[ $key == "Filename" ]]; then
                    val=${${line#*:}:t}
                fi

                # Vertical align values
                print -f "%-${key_max}s %s\n" "$key" "$val"
            else
                # Underline section titles
                if $first_section; then
                    print -P "\e[4m${line% }\e[0m"
                    first_section=false
                else
                    print -P "\n\e[4m${line% }\e[0m"
                fi
            fi
        done
    else
        file --brief "$1"
    fi
}

draw_image() {
    if is_command chafa; then
        chafa --size=${width}x$((height/2)) --animate=false "$file"
        echo ""
    fi
}

mime_type=$(file --mime-type --brief "$file")
file_type=${mime_type%/*}
subtype=${mime_type#*/}

case "$file_type" in
    image)
        draw_image
        print_info "$file"
        ;;
    audio|video)
        print_info "$file"
        ;;
    application)
        if [[ "$subtype" == "octet-stream" ]] && \
           [[ "$(file --brief "$file")" == "Audio file with ID3"* ]]; then
            print_info "$file"
        else
            exit 1
        fi
        ;;
    *)
        exit 1
        ;;
esac
exit 0

