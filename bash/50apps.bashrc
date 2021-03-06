# -*-sh-*-
#
# apps.bashrc - Shell aliases and program environment (lesspipe)
#

# Pager configuration
if [ -x /usr/bin/lesspipe ]; then
    # Rewrite some non-text files; do syntax highlighting.
    if [ -e /etc/debian_version ]; then eval "$(lesspipe)"
    else export LESSOPEN="|lesspipe %s"; fi
fi
export LESS=-iR
export PAGER=less

# Default web browser
export BROWSER=firefox

# Enable colors in ls
export CLICOLOR=1               # Enable on Mac OS X (same as ls -G)
[ -n "$(type -t dircolors)" ] && eval "$(dircolors -b)" # GNU extended colors

# Enable colors in gcc
export GCC_COLORS=1             # Use default colors. GCC >= 4.9

# Probe a command for acceptable command-line arguments.
# Usage: _probe_args <command> <testsuffix> <testcriteria> <arg> [...]
_probe_args() {
    local cmd args testsuffix testcriteria arg
    cmd="$1"
    testsuffix="$2"
    testcriteria="$3"
    shift 3
    args="$cmd"
    for arg in "$@"; do
        # Try command with this argument
        command $args $arg $testsuffix </dev/null >/dev/null 2>&1
        if [ $testcriteria "$?" ]; then
            args="$args $arg"
        fi
    done
    echo "$args"
}
# Cache the results of the probe for each host
_probe_args_cache=~/.cache/bashrc-probe-args.$USER@$HOSTNAME
if [ -r "$_probe_args_cache" ] && [ "$_probe_args_cache" -nt ~/.bashrc ]; then
    . "$_probe_args_cache"
else
    alias ls="$(_probe_args ls '-d /' '0 -eq' -lh --color=auto)"
    alias grep="$(_probe_args grep '. /dev/null' '2 -gt' --color=auto)"
    [ -d ~/.cache ] && alias ls grep > "$_probe_args_cache"
fi
unset _probe_args _probe_args_cache

# A calculator
if [ -n "$(type -t calc)" ]; then
    alias c=calc
else           # If calc isn't available, use this simple hack instead
    alias c="perl -le \"print eval join ' ', @ARGV;\""
fi

alias +=pushd -=popd

if [ -n "$(type -t xdg-open)" ]; then
    open() {
        local x
        [ "$#" = 0 ] && echo 'Usage: open <file> [...]' >&2 && return 2
        for x in "$@"; do
            xdg-open "$x"
        done
    }
fi

# Misspellings
alias xit=exit
alias kilall=killall

# Use Perl version of rename
if [ -n "$(type -t file-rename)" ]; then
    alias rename=file-rename
elif [ -n "$(type -t prename)" ]; then
    alias rename=prename
elif [ -n "$(type -t perl-rename)" ]; then
    alias rename=perl-rename
fi

hexcat() {
    local x
    [ "$#" = 0 ] && echo 'Usage: hexcat <file> [...]' >&2 && return 2
    for x in "$@"; do xxd -a "$x"; done
}
alias mtr='mtr --curses'

# Popular examples:
# alias rm='rm -i'		# interactive delete
# alias cp='cp -i'		# interactive copy
# alias mv='mv -i'		# interactive move
# alias less='less -r'		# raw control characters
# alias ll='ls -l'		# long list
# alias la='ls -A'		# all but . and ..
# alias l='ls -CF'		#

# SSH hosts
# alias foo='ssh foo'
