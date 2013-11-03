# -*-sh-*-
#
# prompt.bashrc - Prompt and Title
#

# http://en.wikipedia.org/wiki/ANSI_escape_code#Colors
if [ "$USER" = root ]; then
    _COLOR=31                   # Red for root shells
elif [ -n "$SSH_CLIENT" ]; then
    _COLOR=35                   # Magenta for remote shells
    # Yellow (33) doesn't work well on a white background
else
    _COLOR=32                   # Green for local shells
fi
#[ "$OPERATING_SYSTEM" = "cygwin" ] &&
#    _USER=$(echo $USER@ | tr '[:upper:]' '[:lower:]')
[ "$USER" = "root" ] && _USER=$USER@ # Display username if unexpected
# Modify capitalization of $USER, because it may be unexpected in cygwin
case "$TERM" in
    xterm*|rxvt*|cygwin*|screen*) # Color and title bar available
        # Bashisms are okay in PROMPT_COMMAND, as it is a bashism itself.
        if [ -n $(type -t title) ]; then
            _TITLE='$USER@${HOSTNAME%%.*}: ${PWD/#$HOME/~}'
            PROMPT_COMMAND='title -a "'"$_TITLE"'"'
            # Current command in titlebar.
            _NO_CMD_TITLEBAR=1
            trap '[[ "$BASH_COMMAND" = "title -a"* || "$BASH_COMMAND" = "exit"* || -n "$_NO_CMD_TITLEBAR" ]] || title -a -- "$BASH_COMMAND - '"$_TITLE"'"' DEBUG
            unset _TITLE
        fi
        PS1="\[\033[01;${_COLOR}m\]$_USER\h\[\033[01;34m\] \w\$\[\033[00m\] "
        ;;
    vt100*|linux*)              # Color only
        PS1="\[\033[01;${_COLOR}m\]$_USER\h\[\033[01;34m\] \w\$\[\033[00m\] "
	;;
    *)
        PS1="$_USER\h \w\$ "  # Plain user@host ~$ or host ~$
	;;
esac
# This should be the last thing in the bashrc,
# since it will enable commands in the titlebar
unset _COLOR _USER
