# -*-sh-*-
#
# title.bashrc - Title command for setting the titlebar
#

title() {
    # Handle command-line flags
    local OPT_AUTO=0 FLAG='?' OPTIND=1
    while getopts a FLAG 2>/dev/null; do
        case "$FLAG" in
            a)
                OPT_AUTO=1
                ;;
            *)
                echo "Usage: ${FUNCNAME:-title} [-a] <title>" >&2
                echo "       ${FUNCNAME:-title}" >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))
    if [ "$#" -eq 0 ]; then
	unset MANUAL_TITLE
	return
    elif [ "$OPT_AUTO" -eq 1 ] && [ -n "$MANUAL_TITLE" ]; then
	# If the title is manually set do not autoset the title
	return
    elif [ "$OPT_AUTO" -eq 0 ]; then
	MANUAL_TITLE=1
    fi
    printf "\033]0;%s\007" "$*"
}
