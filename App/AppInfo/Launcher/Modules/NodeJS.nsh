Var NodeJSDir
Var ChangeNPMPrefix

${SegmentFile}

${SegmentPreExec}
	${ReadUserConfig} "$NodeJSDir" "NodeJSDir"
	ExpandEnvStrings "$NodeJSDir" "$NodeJSDir"

	${If} ${FileExists} "$NodeJSDir\node.exe"
		${ReadUserConfig} "$ChangeNPMPrefix" "ChangeNPMPrefix"
		${If} "$ChangeNPMPrefix" == "true"
			; Force change NPM user prefix and cache directory
			; The default locations are "%AppData%\npm" and "%AppData%\npm-cache"
			${SetEnvironmentVariablesPath} "NPM_CONFIG_PREFIX" "$DataDir\misc\AppData\Roaming\npm"
			${SetEnvironmentVariablesPath} "NPM_CONFIG_CACHE" "$DataDir\misc\AppData\Roaming\npm-cache"

			; Create the directory to prevent error
			CreateDirectory "$DataDir\misc\AppData\Roaming\npm"
			CreateDirectory "$DataDir\misc\AppData\Roaming\npm-cache"
		${EndIf}

		; Get prefix directory and add it to "PATH"
		nsExec::ExecToStack '"$CmdPath" /C ""$NodeJSDir\npm.cmd" config get prefix"'
		Pop $R1

		${If} $R1 == 0
			Pop $R2
			; Trim trailing newline from npm output
			; This will break "PATH" if left untouched
			${TrimNewLines} $R2 $R2
			StrCpy "$ExtraPath" "$ExtraPath;$NodeJSDir;$R2"
		${Else}
			StrCpy "$ExtraPath" "$ExtraPath;$NodeJSDir"
		${EndIf}
	${EndIf}
!macroend

${SegmentPostPrimary}
	; Config location for various Node.js packages
	Delete "$PROFILE\.config\configstore\update-notifier-npm.json"
	RMDir "$PROFILE\.config\configstore"
	RMDir "$PROFILE\.config"

	; NPM cache files
	${If} "$ChangeNPMPrefix" == "true"
		RMDir /r "$DataDir\misc\AppData\Roaming\npm-cache"
	${EndIf}

	; Stub NPM directories
	RMDir "$APPDATA\npm-cache"
	RMDir "$APPDATA\npm"
!macroend