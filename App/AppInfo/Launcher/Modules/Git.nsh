Var GitDir
Var ChangeUnixHome

${SegmentFile}

${SegmentPreExec}
	${ReadUserConfig} "$GitDir" "GitDir"
	ExpandEnvStrings "$GitDir" "$GitDir"

	${If} ${FileExists} "$GitDir\cmd\git.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$GitDir\cmd;$GitDir\bin"

		; Change Git home directory (may affect MinGW, MSYS, and other Unix emulated programs)
		; The default is "%UserProfile%", which can be dirty if there are too many config files
		${ReadUserConfig} "$ChangeUnixHome" "ChangeUnixHome"
		${If} "$ChangeUnixHome" == "true"
			${SetEnvironmentVariablesPath} "HOME" "$DataDir\misc"
			CreateDirectory "$DataDir\misc"

			; Also copy custom shell config (Bash and Zsh) if they don't exist yet
			; This will make an alias for "cd" command so it will still point to "%UserProfile%"
			; If you're using mod like Oh My Zsh, this file may get overwritten, so copy manually again
			${IfNot} ${FileExists} "$DataDir\misc\.bashrc"
				CopyFiles /Silent "$DefaultDataDir\misc\.bashrc" "$DataDir\misc"
			${EndIf}

			${IfNot} ${FileExists} "$DataDir\misc\.zshrc"
				CopyFiles /Silent "$DefaultDataDir\misc\.zshrc" "$DataDir\misc"
			${EndIf}
		${EndIf}

		${If} ${FileExists} "$GitDir\post-install.bat"
			; Git post installation script (if you're using the portable edition)
			nsExec::Exec '"$CmdPath" /C ""$GitDir\post-install.bat""'
		${EndIf}
	${EndIf}
!macroend