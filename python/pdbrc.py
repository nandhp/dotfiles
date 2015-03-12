#?install ~/.pdbrc.py -*-python-*-
#
# pdbrc.py - Advanced configuration for the Python debugger
#

# https://wiki.python.org/moin/PdbRcIdea

# Readline: see also pythonrc
try:
    import readline
except ImportError:
    print("Warning: readline module not available")
else:
    # FIXME: improve completion

    # Use a history file
    import os, atexit
    histfile = os.path.expanduser('~/.pdb_history')
    try:
        readline.read_history_file(histfile)
    except IOError:
        pass
    # Write history file at exit. FIXME: merge history file
    atexit.register(readline.write_history_file, histfile)
    del histfile, atexit, os
    readline.set_history_length(500)

    del readline
