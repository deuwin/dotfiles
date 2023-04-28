# Symbol Meanings
A reference of symbol meanings in Impure prompt.

## Prompt
| Symbol | Unicode  | Meaning                            |
|:-------|:---------|:-----------------------------------|
| `…`    | `\u2026` | Directory truncation               |
| `✗`    | `\u2717` | Previous command exited with error |
| `✦N`   | `\u2726` | `N` background jobs                |
| `↵`    | `\u21B5` | Prompt continues on new line       |

## Git Repo Information
| Symbol        | Unicode  | Meaning         |
|:--------------|:---------|:----------------|
| ``[^1]       | `\uE0A0` | branch          |
| `∆` (green)   | `\u2206` | unstaged        |
| `∆` (orange)  | `\u2206` | staged          |
| `?`           |          | untracked       |
| `≡`           | `\u2261` | stashed         |
| `⇣`           | `\u21E3` | behind remote   |
| `⇡`           | `\u21E1` | ahead of remote |
| `✗`           | `\u2717` | deleted files   |


## Alternate Symbols
Some nice alternatives seen/stolen from other git setups or discovered while
perusing [Unicode tables](https://codepoints.net/) or
[Nerd Fonts](https://www.nerdfonts.com/), in case you prefer them.

### Prompt
#### Prompt Symbol
| Symbol | Unicode  |
|:-------|:---------|
| `$`    |          |
| `>`    |          |
| `»`    | `\u00BB` |
| `⟫`    | `\u27EB` |
| `》`   | `\u300B` |
| `〉`   | `\u232A` |
| `⟩`    | `\u27E9` |
| `〉`   | `\u3009` |
| `❭`    | `\u276D` |
| `❯`    | `\u276F` |
| `⏵`    | `\u23F5` |

#### Command Error
| Symbol | Unicode  |
|:-------|:---------|
| `✗`    | `\u2717` |
| `✘`    | `\u2718` |

#### Time Taken
Not used but you could add it.
| Symbol | Unicode  |
|:-------|:-------- |
| `⌛`   | `\u231B` |
| `⏳`   | `\u23F3` |
| `⧖`    | `\u29D6` |
| `⧗`    | `\u29D7` |
| `⧗`    | `\u29D7` |
| `⏲`   | `\u23F2` |
| `⟳`    | `\u27F3` |

#### Newline
| Symbol | Unicode  |
|:-------|:-------- |
| `⏎`    | `\u23CE` |
| `↵`    | `\u21B5` |
| `↲`    | `\u21B2` |
| `␤`    | `\u2424` |

### Git
Multiuse symbols, nice if you fancy colouring the symbols.

| Symbol  | Unicode   |
|:--------|:----------|
|   `●`   | `\u25CF`  |

#### Branch
| Symbol  | Unicode   |
|:------- |:----------|
| `λ`     | `\u03BB`  |
| `⎇`     | `\u2387`  |
| `⌥`     | `\u2325`  |
| `ᚴ`     | `\u16B4`  |
| `𐳦`     | `\U10CE6` |
| `𐲦`     | `\U10CA6` |
| ``[^1] | `\uE0A0`  |

#### Changes
Usable for staged and unstaged, or both at the same time if you apply colours.
| Symbol | Unicode   |
|:-------|:----------|
| `+`    |           |
| `✚`    | `\u271A`  |
| `🞦`    | `\U1F7A6` |
| `🞥`    | `\U1F7A5` |
| `δ`    | `\u03B4`  |
| `Δ`    | `\u0394`  |
| `∆`    | `\u2206`  |

#### Staged Changes
| Symbol | Unicode |
|:-------|:--------|
| `✓`    | \u2713  |
| `✔`    | \u2714  |

#### Unstaged Changes
| Symbol | Unicode  |
|:-------|:---------|
| `!`    |          |
| `✶`    | `\u2736` |

#### Deleted Files
| Symbol | Unicode  |
|:-------|:---------|
| `-`    |          |
| `x`    |          |
| `✗`    | `\u2717` |
| `✘`    | `\u2718` |
| `⨯`    | `\u2A2F` |

#### Untracked Files
| Symbol | Unicode  |
|:-------|:---------|
| `?`    |          |
| `…`    | `\u2026` |
| `✩`    | `\u2729` |

#### Renamed/Moved Files
| Symbol | Unicode  |
|:-------|:---------|
| `➜`    | `\u279C` |
| `»`    | `\u00BB` |

#### Behind Remote
| Symbol | Unicode   |
|:-------|:----------|
| `⇣`    | `\u21E3`  |
| `↓`    | `\u2193`  |
| `🡻`    | `\U1F87B` |
| `🠛`    | `\U1F81B` |
| `⯆`    | `\u2BC6`  |

#### Ahead of Remote
| Symbol | Unicode   |
|:-------|:----------|
| `⇡`    | `\u21E1`  |
| `↑`    | `\u2191`  |
| `🡹`    | `\U1F879` |
| `🠙`    | `\U1F819` |
| `⯅`    | `\u2BC5`  |

#### Diverged
Behind and ahead of remote
| Symbol | Unicode   |
|:-------|:----------|
| `⇵`    | `\u21F5`  |
| `⮃`    | `\u2B83`  |
| `⇕`    | `\u21D5`  |
| `⭥`    | `\u2B65`  |
| `⬍`    | `\u2B0D`  |
| `🡙`    | `\U1F859` |
| `↕`    | `\u2195`  |


#### Stashed Changes
| Symbol | Unicode  |
|:-------|:---------|
| `$`    |          |
| `*`    |          |
| `⚑`    | `\u2691` |
| `≡`    | `\u2261` |

#### Conflict
| Symbol | Unicode  |
|:-------|:---------|
| `=`    |          |
| `≠`    | `\u2260` |

# Bibliography
[Spaceship](https://spaceship-prompt.sh/)  
[Oh My Zsh - Git Prompt](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-prompt)  
[Gitmux](https://github.com/arl/gitmux)  
[Starship](https://starship.rs/config/#git-state)  
[Pure](https://github.com/sindresorhus/pure)  
[Purity](https://github.com/therealklanni/purity)  


[^1]: From [Nerd Fonts](https://www.nerdfonts.com/)
