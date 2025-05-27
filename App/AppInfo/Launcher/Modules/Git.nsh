Var GitDir
Var ChangeUnixHome

${SegmentFile}

${SegmentPreExec}
	${ReadCustomConfig} "$GitDir" "Git" "Path" "%PAL:CommonFilesDir%\Git"
	ExpandEnvStrings "$GitDir" "$GitDir"

	${If} ${FileExists} "$GitDir\cmd\git.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$GitDir\cmd;$GitDir\bin"

		; Change Git home directory (the default is "%UserProfile%")
		; May also affect MinGW, MSYS, and other Unix emulated programs
		${ReadCustomConfig} "$ChangeUnixHome" "Git" "ChangeUnixHome" "true"
		${If} "$ChangeUnixHome" == "true"
			${SetEnvironmentVariablesPath} "HOME" "$DataDir\misc"
			CreateDirectory "$DataDir\misc"

			${If} "$IsFirstRun" == "true"
				CopyFiles "$FirstRunDir\misc\.bashrc" "$DataDir\misc"
				CopyFiles "$FirstRunDir\misc\.zshrc" "$DataDir\misc"
			${EndIf}
		${EndIf}

		${If} ${FileExists} "$GitDir\post-install.bat"
			; Execute post install script if using Git Portable
			; Double quoted in case there's space in the path
			${RunCmd} '"$GitDir\post-install.bat"'
		${EndIf}
	${EndIf}
!macroend