Var NodeJSDir
Var ChangeNpmPrefix
Var DeleteNpmCacheOnExit

${SegmentFile}

${SegmentPreExec}
	${ReadCustomConfig} "$NodeJSDir" "NodeJS" "Path" "%PAL:CommonFilesDir%\NodeJS"
	ExpandEnvStrings "$NodeJSDir" "$NodeJSDir"

	${If} ${FileExists} "$NodeJSDir\node.exe"
		${ReadCustomConfig} "$ChangeNpmPrefix" "NodeJS" "ChangeNpmPrefix" "true"
		${If} "$ChangeNpmPrefix" == "true"
			; Change npm user prefix and cache directory
			; The default locations are "%AppData%\npm" and "%AppData%\npm-cache"
			${SetEnvironmentVariablesPath} "NPM_CONFIG_PREFIX" "$DataDir\misc\AppData\Roaming\npm"
			${SetEnvironmentVariablesPath} "NPM_CONFIG_CACHE" "$DataDir\misc\AppData\Roaming\npm-cache"

			; Create the directory to prevent error
			CreateDirectory "$DataDir\misc\AppData\Roaming\npm"
			CreateDirectory "$DataDir\misc\AppData\Roaming\npm-cache"
		${EndIf}

		; Get prefix directory and add it to "PATH"
		${RunCmdToStack} '"$NodeJSDir\npm.cmd" config get prefix'
		Pop $R1

		${If} $R1 == 0
			Pop $R2
			; Trim trailing newline from the npm output
			; This will break "PATH" on some shells if left untouched
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

	; Npm cache files
	${If} "$ChangeNpmPrefix" == "true"
		${ReadCustomConfig} "$DeleteNpmCacheOnExit" "NodeJS" "DeleteNpmCacheOnExit" "true"
		${If} "$DeleteNpmCacheOnExit" == "true"
			RMDir /r "$DataDir\misc\AppData\Roaming\npm-cache"
		${EndIf}
	${EndIf}

	; Npm stub directories
	RMDir "$APPDATA\npm-cache"
	RMDir "$APPDATA\npm"
!macroend