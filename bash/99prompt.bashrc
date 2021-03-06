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
        # Some system bashrc files come with PROMPT_COMMAND preset to
        # set the window or screen window name. Remove them. We cannot
        # simply clear the PROMPT_COMMAND since some of them are useful.
        if [ -n "$PROMPT_COMMAND" -a -n "$BASH" ]; then
            _TEMP="${PROMPT_COMMAND#*\033}"
            if [ "${_TEMP:0:3}" = "]0;" ] || # Set title/hardstatus
                   [ "${_TEMP:0:1}" = "k" ]; then # Screen window name
                PROMPT_COMMAND=
            fi
            unset _TEMP
        fi
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
                [ -w $_FD255 ] && [[ "$(readlink $_FD255)" = /dev/pts* ]] && \
                    trap '[[ -n "$_NO_CMD_TITLEBAR" || "$BASH_COMMAND" = "_NO_CMD_TITLEBAR="* || "$BASH_COMMAND" = "title -a"* || "$BASH_COMMAND" = "exit"* ]] || title -a -- "${BASH_COMMAND//[[:cntrl:]]/ } - '"$_TITLE"'" >&255' DEBUG
                unset _FD255
            fi
            # Remove trailing semicolon from some system profiles (Mac OS X)
            _OLD_PROMPT_COMMAND="${PROMPT_COMMAND%; }"
            _OLD_PROMPT_COMMAND="${_OLD_PROMPT_COMMAND%;}"
            # The above simplifies to ${PROMPT_COMMAND%%*([; ])} if
            # extglob is turned on.
            [ -n "$_OLD_PROMPT_COMMAND" ] && \
                _OLD_PROMPT_COMMAND="$_OLD_PROMPT_COMMAND;"
            PROMPT_COMMAND='_NO_CMD_TITLEBAR=1; title -a "'"$_TITLE"'"; '"$_OLD_PROMPT_COMMAND"' unset _NO_CMD_TITLEBAR'
            unset _TITLE _OLD_PROMPT_COMMAND
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
