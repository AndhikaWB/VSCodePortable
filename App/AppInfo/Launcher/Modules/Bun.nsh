Var BunDir
Var ChangeBunInstall
Var DeleteBunCacheOnExit

${SegmentFile}

${SegmentPreExec}
	${ReadCustomConfig} "$BunDir" "Bun" "Path" "%PAL:CommonFilesDir%\Bun"
	ExpandEnvStrings "$BunDir" "$BunDir"

	; Please create the "bin" folder manually if needed
	; The official Bun documentation uses this folder structure
	${If} ${FileExists} "$BunDir\bin\bun.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$BunDir\bin"

		; Change Bun install directory (the default is "%UserProfile%\.bun")
		; https://github.com/oven-sh/bun/issues/12886
		${ReadCustomConfig} "$ChangeBunInstall" "Bun" "ChangeBunInstall" "true"
		${If} "$ChangeBunInstall" == "true"
			${SetEnvironmentVariablesPath} "BUN_INSTALL" "$DataDir\misc\.bun"
			StrCpy "$ExtraPath" "$ExtraPath;$DataDir\misc\.bun\bin"
		${EndIf}

		; Disable Bun telemetry
		${SetEnvironmentVariablesPath} "DO_NOT_TRACK" "1"
	${EndIf}
!macroend

${SegmentPostPrimary}
	; Bun install cache files
	${If} "$ChangeBunInstall" == "true"
		${ReadCustomConfig} "$DeleteBunCacheOnExit" "Bun" "DeleteBunCacheOnExit" "true"
		${If} "$DeleteBunCacheOnExit" == "true"
			RMDir /r "$DataDir\misc\.bun\install\cache"
		${EndIf}
	${EndIf}

	; Bun stub directories
	RMDir "$PROFILE\.bun\install\cache"
	RMDir "$PROFILE\.bun\install"
	RMDir "$PROFILE\.bun"
!macroend