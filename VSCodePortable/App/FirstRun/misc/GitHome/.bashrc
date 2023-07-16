# Change back home directory (for cd only)
# Place it at the end of file to avoid issues
alias cd="HOME=$(cygpath -u "$USERPROFILE") cd"
