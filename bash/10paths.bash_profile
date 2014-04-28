# -*-sh-*-
#
# paths.bash_profile - Add entries to PATH, MANPATH, and INFOPATH
#

# Add a directory PATH without duplication
_pathmunge() {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ]; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}

# Add personal bin directory to PATH
if [ -d ~/.local/bin  ]; then _pathmunge ~/.local/bin
else
    [ -d ~/bin ] && _pathmunge ~/bin
    [ -d ~/perl ] && _pathmunge ~/perl
fi
# Update MANPATH and INFOPATH
if [ -d ~/.local/share/man  ]; then MANPATH=~/.local/share/man:$MANPATH
elif [ -d ~/.local/man ]; then MANPATH=~/.local/man:$MANPATH
fi
if [ -d ~/.local/share/info ]; then INFOPATH=~/.local/share/info:$INFOPATH
elif [ -d ~/.local/info ]; then INFOPATH=~/.local/info:$INFOPATH
fi

# Add xscreensaver and sbin to PATH
for x in /usr/lib/xscreensaver /usr/lib/misc/xscreensaver \
    /usr/libexec/xscreensaver \
    /usr/local/sbin /usr/sbin /sbin; do
    [ -d $x ] && _pathmunge $x after
done

# Cleanup
unset x _pathmunge

# Export new environment variables
export PATH MANPATH INFOPATH
