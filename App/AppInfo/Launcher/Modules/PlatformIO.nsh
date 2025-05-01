Var ChangePlatformIOCore

${SegmentFile}

${SegmentPreExec}
	${ReadUserConfig} "$ChangePlatformIOCore" "ChangePlatformIOCore"
	${If} "$ChangePlatformIOCore" == "true"
		; Change PlatformIO core path (the default is "%UserProfile%\.platformio")
		; https://docs.platformio.org/en/latest/envvars.html
		${SetEnvironmentVariablesPath} "PLATFORMIO_CORE_DIR" "$DataDir\misc\.platformio"
	${EndIf}
!macroend