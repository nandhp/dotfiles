#?install ~/.gdbinit
#
# gdbinit - GDB configuration
#

# Don't confirm quit
set confirm off

# Save history
set history filename ~/.gdb_history
set history save
set history size 1000

# Needed for some systems with newer gcc
add-auto-load-safe-path /opt/apps
