# -*-sh-*-
#
# prompt.bashrc - Prompt and Title
#

# http://en.wikipedia.org/wiki/ANSI_escape_code#Colors
if [ "$USER" = root ]; then
    _COLOR=31                   # Red for root shells
elif [ -n "$SSH_CONNECTION" ]; then
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
            _TITLE='$USER@${HOSTNAME%%.*}'
            # The Mac OS X Terminal has special features for the cwd
            # and running command; don't replace them.
            if ! type -t update_terminal_cwd >/dev/null 2>&1; then
                _TITLE="$_TITLE"': ${PWD/#$HOME/~}'
                # Current command in titlebar.
                _NO_CMD_TITLEBAR=1
                # Use bash file descriptor 255, which should be the
                # console, to avoid conflicts with I/O redirection.
                # Verify it points to /dev/pts*. (This check may fail
                # in some exotic environments, including OS X and real
                # TTYs; in such cases, the command will not appear in
                # the titlebar.)
                _FD255=/proc/$$/fd/255
                [ -e $_FD255 ] && [[ "$(readlink $_FD255)" = /dev/pts* ]] && \
                    trap '[[ "$BASH_COMMAND" = "title -a"* || "$BASH_COMMAND" = "update_terminal_cwd"* || "$BASH_COMMAND" = "exit"* || -n "$_NO_CMD_TITLEBAR" ]] || title -a -- "$BASH_COMMAND - '"$_TITLE"'" >&255' DEBUG
                unset _FD255
                # FIXME: strip control characters (e.g. tab)
            fi
            PROMPT_COMMAND='title -a "'"$_TITLE"'"; '"$PROMPT_COMMAND"
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
