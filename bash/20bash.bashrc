# -*-sh-*-
#
# bash.bashrc - bash behavior configuration (shopt, completion, history)
#

# Shell Options
set -o notify		 	# Don't wait for job termination notification
set -o ignoreeof		# Don't use ^D to exit
# shopt -s nocaseglob		# Use case-insensitive filename globbing
# shopt -s cdspell		# Ignore typos in cd (e.g. /vr/lgo/apaache)
shopt -s checkwinsize		# Update LINES and COLUMNS in case of resize
# CDPATH=.:~                      # DO NOT export to other processes

# Completion options

# Complete remotely checked-out files over passwordless ssh for CVS
# COMP_CVS_REMOTE=1
# Don't strip description in --option=description of './configure --help'
# COMP_CONFIGURE_HINTS=1
# Don't flatten internal contents of tar files
# COMP_TAR_INTERNAL_PATHS=1

# If this shell is interactive, turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
elif [ -f /etc/profile.d/bash-completion.sh ]; then
    . /etc/profile.d/bash-completion.sh
fi

# History configuration: don't save in history duplicate lines or
# lines beginning with space.
export HISTCONTROL=ignoredups:ignorespace
# export HISTIGNORE="[   ]*:&:bg:fg:exit" # Ignore some job control, etc.
# export PROMPT_COMMAND="history -a" # Autosave history every time
export HISTFILESIZE=50000
export HISTSIZE=50000
export HISTTIMEFORMAT="%F %T "
shopt -s histappend		# Append rather than overwrite history on disk
