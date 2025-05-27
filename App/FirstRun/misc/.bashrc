# Force save Bash history
# https://unix.stackexchange.com/q/1288
# https://unix.stackexchange.com/q/18212
shopt -s histappend
HISTCONTROL=ignoredups:erasedups
PROMPT_COMMAND="history -a;${PROMPT_COMMAND#"history -a;"}"
trap "history -n;history -w;history -c;history -r" EXIT

# Hook Conda to the shell only when needed
# https://github.com/conda/conda/issues/11648
alias conda="__conda_init && conda"
function __conda_init() {
    if [ -x "$(type -P conda)" ]; then
		CONDA_EXE="$(type -P conda)"
		if [ -z "$CONDA_INITIALIZED" ]; then
			CONDA_INITIALIZED=true
			"$CONDA_EXE" config --set changeps1 False
			"$CONDA_EXE" config --set auto_activate_base false
			eval "$("$CONDA_EXE" shell.bash hook)" &&
				unset -f __conda_init &&
				unalias conda
		fi
	fi
}

# Change back home directory (for cd only)
# Place it at the end of the file to avoid issues
alias cd="HOME=$(cygpath -u "$USERPROFILE") cd"
