# Modified from Git/etc/zsh/zshenv
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html

function __get_python_env() {
	if [ -n "$VIRTUAL_ENV" ]; then
		echo "($VIRTUAL_ENV)"
	elif [ -n "$CONDA_DEFAULT_ENV" ]; then
		echo "($CONDA_DEFAULT_ENV)"
	fi
}

# Username
PROMPT="%B%F{red}%n%f "
# Current working directory
PROMPT="$PROMPT""%F{yellow}%~%f "
# Python environment
PROMPT="$PROMPT""%F{green}`__get_python_env`%f"$'\n'
# Prompt
PROMPT="$PROMPT""%F{cyan}%#%f%b "
