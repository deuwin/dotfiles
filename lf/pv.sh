#!/bin/sh
# (1) current file name
# (2) width
# (3) height
# (4) horizontal position
# (5) vertical position of preview pane

LESSQUIET=1 less --RAW-CONTROL-CHARS -+--quit-if-one-screen "$1"

