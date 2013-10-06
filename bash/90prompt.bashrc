# -*-sh-*-
#
# prompt.bashrc - Prompt and Title
#

if [ "$USER" = root ]; then
    _COLOR=31                   # Red for root shells
elif [ -n "$SSH_CLIENT" ]; then
    _COLOR=33                   # Yellow for remote shells
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
        [ -n $(type -t title) ] &&
            PROMPT_COMMAND='title -a "$USER@${HOSTNAME%%.*}: ${PWD/#$HOME/~}"'
        ;&                      # bashism
    vt100*|linux*)              # Color only
        PS1="\[\033[01;${_COLOR}m\]$_USER\h\[\033[01;34m\] \w\$\[\033[00m\] "
	;;
    *)
        PS1="$_USER\h \w\$ "  # Plain user@host ~$ or host ~$
	;;
esac
unset _COLOR _USER
