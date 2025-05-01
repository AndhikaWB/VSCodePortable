Var GoDir
Var ChangeGoPath

${SegmentFile}

${SegmentPreExec}
	${ReadUserConfig} "$GoDir" "GoDir"
	ExpandEnvStrings "$GoDir" "$GoDir"

	${If} ${FileExists} "$GoDir\bin\go.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$GoDir\bin"

		${ReadUserConfig} "$ChangeGoPath" "ChangeGoPath"
		${If} "$ChangeGoPath" == "true"
			; Change "GOPATH" directory (the default is "%UserProfile%\Go")
			; https://go.dev/wiki/GOPATH
			${SetEnvironmentVariablesPath} "GOPATH" "$DataDir\misc\Go"

			; Just in case there are executable files in there
			StrCpy "$ExtraPath" "$ExtraPath;$DataDir\misc\Go\bin"
		${EndIf}

		; Disable telemetry
		nsExec::Exec '"$CmdPath" /C ""$GoDir\bin\go.exe" telemetry off"'
	${EndIf}
!macroend

${SegmentPostPrimary}
	; Go build cache files
	RMDir /r "$LOCALAPPDATA\go-build"

	; Go telemetry files
	RMDir /r "$APPDATA\go\telemetry"
	RMDir "$APPDATA\go"

	; Go language server and lint files
	RMDir /r "$LOCALAPPDATA\gopls"
	RMDir /r "$LOCALAPPDATA\staticcheck"
!macroend