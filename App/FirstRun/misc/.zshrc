# Force save Zsh history
# https://linux.die.net/man/1/zshoptions
setopt INC_APPEND_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Hook Conda to the shell only when needed
# https://github.com/conda/conda/issues/11648
alias conda="__conda_init && conda"
function __conda_init() {
    if [ -x "$(whence -cp conda)" ]; then
		CONDA_EXE="$(whence -cp conda)"
		if [ -z "$CONDA_INITIALIZED" ]; then
			CONDA_INITIALIZED=true
			"$CONDA_EXE" config --set changeps1 False
			"$CONDA_EXE" config --set auto_activate_base false
			eval "$("$CONDA_EXE" shell.zsh hook)" &&
				unset -f __conda_init &&
				unalias conda
		fi
	fi
}

# Change back home directory (for cd only)
# Place it at the end of the file to avoid issues
alias cd="HOME=$(cygpath -u "$USERPROFILE") cd"
