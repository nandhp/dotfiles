# -*-sh-*-
#
# interactive-only.bashrc - Return if shell is noninteractive
#
# bashrc customizations applicable to non-interactive shells are
# supported with priority less than 10.
#

# Only customize interactive shells
[ -z "$PS1" ] && return

# OPERATING_SYSTEM=$(uname -s)
[ -z "$USER" ] && USER=$(id -u -n)
[ -z "$HOSTNAME" ] && HOSTNAME=$(hostname)
# LOGNAME? USERNAME?
