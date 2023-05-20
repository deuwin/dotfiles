# Font Fallback
`fonts.conf` sets a custom font family that can be used by Alacritty to help
ensure decent rendering of NerdFont symbols and other code points within the
wider Unicode standard.

First saw this
[here](https://blog.sebastian-daschner.com/entries/linux-terminal-font-alacritty-jetbrains-mono-emoji).
Didn't care for the emojis, but did want the occasional piece of Unicode to
render well.

## Editing and Testing
You might want to specify a particular font before falling back to something
generically monospace. To list available monospace fonts:

```shell
fc-list :mono | awk -F: '{print $2}' | sort | uniq
```

After making changes to `fonts.conf` you need to:
  1. Run this command:

      ```shell
      sudo fc-cache -fr
      ```

  2. Restart your terminal program.

The previous command will erase existing cache files and regenerate new cache
files.

