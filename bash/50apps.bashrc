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

# Editor configuration (FIXME: emacsify)
export EDITOR=nano
export VISUAL=nano

# Default web browser
export BROWSER=firefox

# Configure ls
eval "$(dircolors -b)"          # Full color support
alias ls='ls -lh --color=auto --dereference-command-line-symlink-to-dir'

# A calculator
if [ -n "$(type -t calc)" ]; then
    alias c=calc
else           # If calc isn't available, use this simple hack instead
    alias c="perl -le \"print eval join ' ', @ARGV;\""
fi

alias +=pushd -=popd
alias grep='grep --color=auto'	# show matches in colour
alias open=xdg-open

# Misspellings
alias xit=exit
alias kilall=killall

# Use Perl version of rename
if [ -n "$(type -t prename)" ]; then
    alias rename=prename
elif [ -n "$(type -t perl-rename)" ]; then
    alias rename=perl-rename
fi

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
