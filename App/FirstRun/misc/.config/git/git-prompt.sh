# Modified from Git/etc/profile.d/git-prompt.sh
# https://medium.com/@damianczapiewski/c69eb9ef0125

function __get_python_env() {
	if [ -n "$VIRTUAL_ENV" ]; then
		echo "($VIRTUAL_ENV)"
	elif [ -n "$CONDA_DEFAULT_ENV" ]; then
		echo "($CONDA_DEFAULT_ENV)"
	fi
}

# Window title
PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]'
# Bold text
PS1="$PS1"'\e[1m'
# Username
PS1="$PS1"'\[\033[31m\]\u '
# Current working directory
PS1="$PS1"'\[\033[33m\]\w '
# Python environment
PS1="$PS1"'\[\033[32m\]`__get_python_env`\n'
# Prompt
PS1="$PS1"'\[\033[36m\]> '
# Reset bold text and color
PS1="$PS1"'\e[0m\[\033[0m\]'
