Var FlutterDir
Var ChangePubCache

${SegmentFile}

${SegmentPreExec}
	${ReadUserConfig} "$FlutterDir" "FlutterDir"
	ExpandEnvStrings "$FlutterDir" "$FlutterDir"

	; Just check for Dart as Flutter uses it too
	${If} ${FileExists} "$FlutterDir\bin\dart.bat"
		StrCpy "$ExtraPath" "$ExtraPath;$FlutterDir\bin"

		; Disable telemetry and analytics
		nsExec::Exec '"$CmdPath" /C ""$FlutterDir\bin\flutter.bat" config --no-analytics"'
		nsExec::Exec '"$CmdPath" /C ""$FlutterDir\bin\flutter.bat" --disable-telemetry"'
		nsExec::Exec '"$CmdPath" /C ""$FlutterDir\bin\dart.bat" --disable-analytics"'
		nsExec::Exec '"$CmdPath" /C ""$FlutterDir\bin\dart.bat" --disable-telemetry"'

		; Change Pub cache directory (the default is "%LocalAppData%\Pub\Cache")
		${ReadUserConfig} "$ChangePubCache" "ChangePubCache"
		${If} "$ChangePubCache" == "true"
			${SetEnvironmentVariablesPath} "PUB_CACHE" "$DataDir\misc\AppData\Local\Pub\Cache"
		${EndIf}

		; Also configure Android Studio directory if exists
		${If} "$AndroidStudioExists" == "true"
			nsExec::Exec '"$CmdPath" /C ""$FlutterDir\bin\flutter.bat" config --android-studio-dir="$AndroidStudioDir""'
		${EndIf}
	${EndIf}
!macroend

${SegmentPostPrimary}
	; Dart analysis server files
	RMDir /r "$LOCALAPPDATA\.dartServer"
!macroend