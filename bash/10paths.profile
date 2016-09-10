# -*-sh-*-
#
# paths.profile - Add entries to PATH, MANPATH, and INFOPATH
#

# Add a directory to a path variable without duplication (uses
# temporary _PATH variable)
_pathmunge() {
    case ":$_PATH:" in
        *:"$1":*)
            ;;
        *)
            if [ -z "$_PATH" ]; then
                _PATH="$1"
            elif [ "$2" = "after" ]; then
                _PATH="$_PATH:$1"
            else
                _PATH="$1:$_PATH"
            fi
    esac
}

_PATH="$PATH"

# Add personal bin directory to PATH
if [ -d ~/.local/bin  ]; then _pathmunge ~/.local/bin
else
    [ -d ~/bin ] && _pathmunge ~/bin
    [ -d ~/perl ] && _pathmunge ~/perl
fi

# Add xscreensaver and sbin to PATH
for x in /usr/lib/xscreensaver /usr/lib/misc/xscreensaver \
    /usr/libexec/xscreensaver \
    /usr/local/sbin /usr/sbin /sbin; do
    [ -d $x ] && _pathmunge $x after
done

export PATH="$_PATH"
_PATH="$LD_LIBRARY_PATH"

# Add personal lib directory to LD_LIBRARY_PATH
[ -d ~/.local/lib  ] && _pathmunge ~/.local/lib

export LD_LIBRARY_PATH="$_PATH"
_PATH="$MANPATH"

# Add personal man pages to MANPATH
if [ -d ~/.local/share/man  ]; then _pathmunge ~/.local/share/man
elif [ -d ~/.local/man ]; then _pathmunge ~/.local/man
fi

# Some systems have broken MANPATH handling (empty entry does not
# imply default search path). Since on these systems we will be more
# likely than average to want man pages, let's avoid breaking them by
# converting our PATH to a MANPATH (in fact, this may actually be an
# improvement if we end up with more man pages than we started with,
# e.g. /opt/gnu/man).
_PATH="$_PATH:"                 # Ensure empty entry exists
for x in $(IFS=:; for x in $PATH; do echo $x; done); do
    x=${x%/*}
    if [ -d "$x/share/man" ]; then _pathmunge "$x/share/man" after
    elif [ -d "$x/man" ]; then _pathmunge "$x/man" after
    fi
done

export MANPATH="$_PATH"
_PATH="$INFOPATH"

# Also add personal info pages to INFOPATH, because why not
if [ -d ~/.local/share/info ]; then _pathmunge ~/.local/share/info
elif [ -d ~/.local/info ]; then _pathmunge ~/.local/info
fi

export INFOPATH="$_PATH"

# Cleanup
unset x _pathmunge _PATH
