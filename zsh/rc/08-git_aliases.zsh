# Inspired by/stolen from:
# https://github.com/davidde/git
# https://github.com/junegunn/fzf/wiki/examples#git
# https://github.com/rothgar/mastering-zsh/blob/master/docs/helpers/functions.md

# tl;dr?
# curl cheat.sh/git

# did you foul up?
# https://dangitgit.com/en

# how does I..?
# https://github.com/k88hudson/git-flight-rules

# pretty manpages
# https://www.mankier.com/package/git-core-doc

## help
alias ghelp="_list_git_aliases"
alias gref="_list_references"

## get stuff
# clone
alias gcl="git clone"
alias gcls="git clone --depth 1" # shallow clone
alias gclcd="_git_clone_cd"
# fetch/pull
alias gf="git fetch --prune"
alias gpl="git pull --rebase"

## go home/toplevel
# gh or gt, whichever your fingers prefer
gh() {
    cd $(git --no-optional-locks rev-parse --show-toplevel)
}
alias gt="gh"

## branch stuff
alias gco="git checkout"                   # switch to branch
alias gcob="git checkout -b"               # new branch
alias gb="git branch"                      # show local branches
alias gba="git branch --all"               # show remote branches as well
alias gbd="git branch --delete"            # delete local branch
alias gbdorigin="git push origin --delete" # delete remote branch

## check stuff
alias gsh="git show"
# commits
alias gl="git log --name-status"
alias glo="git log --pretty=one-line"
alias glp="git log --patch"
# status
alias gs="git status"
alias gs.="git status ."
alias gss="git status -s"                    # short
alias gsto="git status --untracked-files=no" # tracked only
# differences
alias gd="git diff"
alias gd.="git diff ."
alias gds="git diff --staged" # changes between staged and HEAD
alias gdh="git diff HEAD"     # changes between unstaged and HEAD
alias gdp="git --no-pager diff"           # w/o delta
alias gdsp="git --no-pager diff --staged" # w/o delta
# when was <string> committed?
alias gloc="_git_locate_string"
# interactive commit browser
alias fshow="_fzf_commit_browser"

## change stuff
# add
alias ga="git add"
alias gap="git add --patch"
alias gai="git add --interactive"
# (re)move
alias gmv="git mv --verbose"
alias grm="git rm"
alias grmc="git rm --cached"
# rebase
alias grb="git rebase --autostash"
# cherry-pick
alias gcp="git cherry-pick"
alias gcpa="git cherry-pick --abort"
alias gcpc="git cherry-pick --continue"
alias gcpnc="git cherry-pick --no-commit" # pull changes without commit

## fix stuff
alias gca="git commit --amend"
alias grbi="git rebase --interactive"
alias grba="git rebase --abort"
alias grbc="git rebase --continue"

## unchange stuff
alias gr="git restore"
alias grs="git restore --staged"
alias grth="git reset HEAD~"
alias gcof="git checkout --"

## commit stuff
alias gc="git commit --verbose"

## store stuff
alias gst="git stash"
alias gstp="git stash pop"
alias gstl="git stash list"
alias gsts="git stash show"        # list files in stash
alias gstsp="git stash show -p"    # show stash as patch
alias gshsf="_git_show_stash_file" # show file in stash
alias gsta="git stash apply"
alias gstc="git stash clear"
alias gstd="git stash drop"

## push stuff
alias gph="git push"

## manage stuff
# worktrees
alias gw="git worktree"
alias gwl="git worktree list"
# config
alias gcf="git config"
alias gcfl="git config --list"

## ach, to hell with it...
alias yolo="_yolo"
_yolo() {
    # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/lol
    git commit -am "$(curl -s https://whatthecommit.com/index.txt)"
}

## functions
# pretty formatting
if ! git config --get format.pretty > /dev/null; then
    if is_version_gte $(git --version | awk '{print $3}') "2.35.0"; then
        pretty=$(printf "%s" \
            "%C(auto)%H %d%n" \
            "%C(default)📅 %ah · 🖉  %an · ﹫ %ae" \
            "%n%n" \
            "%w(80,4,4)%C(white)%s" \
            "%C(default)%n% b")
        oneline="%C(auto)%h %C(default)%s%C(auto)%d"
    else
        pretty=$(printf "%s" \
            "%C(auto)%H %d%n" \
            "📅 %ah · 🖉  %an · ﹫ %ae" \
            "%n%n" \
            "%w(80,4,4)%C(white)%s" \
            "%C(auto)%n% b")
        oneline="%C(auto)%h %s%d"
    fi
    git config --global format.pretty "format:$pretty"
    # just like `git log --oneline` but tags, etc. after the commit subject
    # can't override built-in aliases so we'll use one-line
    git config --global pretty.one-line "format:$oneline"
    unset oneline pretty
fi

# Locate all commits in which a string was first introduced
_git_locate_string() {
    if [[ -z $1 ]]; then
        echo "Usage: gloc <string> [<file>]"
        return 1
    fi
    gl -S "$1" -- $2
}

_git_clone_cd () {
    if [ -z "$2" ]; then
        git clone "$1" && cd $(basename "$1" ".git")
    else
        git clone "$1" "$2" && cd "$2"
    fi
}

# Show a specified file from stash x (defaults to latest stash):
_git_show_stash_file() {
    if [ -z "$1" ]; then
        echo "Usage: gshsf <file> [<stash number>]"
        return 1
    fi
    git show stash@{${2:-0}}:$1
}

_list_git_aliases() {
    # see man zshmisc
    local git_aliases=${(%):-%x}
    local line
    {
        while IFS= read -r line; do
            [ "$line" = "## help" ] && break
        done
        printf "\e[4m%s\e[0m\n" "${line##\#\# }"

        while IFS= read -r line; do
            case $line in
                "## functions")
                    break
                    ;;
                "    #"*)
                    continue
                    ;;
                "##"*)
                    printf "\e[4m%s\e[0m\n" "${line##\#\# }"
                    ;;
                "# "*)
                    printf "%s\n" "${line##\# }"
                    ;;
                "alias"*)
                    printf "    \e[32m%-10s\e[39m%s\n" \
                        "${${line%%\=*}:6}" "${${line##*\=\"}%\"*}"
                    ;;
                "    "*|[g}_]*)
                    printf "    %s\n" "$line"
                    ;;
                *)
                    printf "%s\n" "$line"
                    ;;
            esac
        done
    } < "$git_aliases" | less --RAW-CONTROL-CHARS
}

_list_references() {
    sed 's/^    //' <<<\
    "Useful references

        tl;dr?
        curl cheat.sh/git

        Did you foul up?
        https://dangitgit.com/en

        How does I..?
        https://github.com/k88hudson/git-flight-rules

        Pretty manpages
        https://www.mankier.com/package/git-core-doc
        "
}

# fshow - git commit browser
if ! is_command fzf; then
    _fzf_commit_browser() {
        printf '%s\n' \
            "Missing required dependancy: fzf" \
            "https://github.com/junegunn/fzf"
        return 1
    }
else
    compdef _files _fzf_commit_browser
    _fzf_commit_browser() {
        local git_show=(
            "echo {} | grep --only-matching '[a-f0-9]\{7\}' |"
            "head --lines=1 | xargs git show --color=always"
        )
        local preview bind
        if command -v delta > /dev/null; then
            preview="| delta"
            pager="| delta --paging always --pager \"less --clear-screen\""
        else
            pager="| less --clear-screen"
        fi

        source "$ZDOTDIR/lib/fzf_preview_args.zsh"
        FZF_DEFAULT_COMMAND="git log --graph --format=one-line --color=always $@" \
            fzf --ansi --no-sort --exact \
                --preview="$git_show$preview" \
                --bind "enter:execute:$git_show$pager" \
                $preview_args
    }
fi

