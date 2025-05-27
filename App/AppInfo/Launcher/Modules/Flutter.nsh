Var FlutterDir
Var ChangePubCache

${SegmentFile}

${SegmentPreExec}
	${ReadCustomConfig} "$FlutterDir" "Flutter" "Path" "%PAL:CommonFilesDir%\Flutter"
	ExpandEnvStrings "$FlutterDir" "$FlutterDir"

	; Just check for Dart as Flutter uses it too
	${If} ${FileExists} "$FlutterDir\bin\dart.bat"
		StrCpy "$ExtraPath" "$ExtraPath;$FlutterDir\bin"

		; Disable Flutter telemetry and analytics
		${RunCmd} '"$FlutterDir\bin\flutter.bat" config --no-analytics'
		${RunCmd} '"$FlutterDir\bin\flutter.bat" --disable-telemetry'
		${RunCmd} '"$FlutterDir\bin\dart.bat" --disable-analytics'
		${RunCmd} '"$FlutterDir\bin\dart.bat" --disable-telemetry'

		; Change Pub cache directory (the default is "%LocalAppData%\Pub\Cache")
		${ReadCustomConfig} "$ChangePubCache" "Flutter" "ChangePubCache" "true"
		${If} "$ChangePubCache" == "true"
			${SetEnvironmentVariablesPath} "PUB_CACHE" "$DataDir\misc\AppData\Local\Pub\Cache"
		${EndIf}

		; Also configure Android Studio directory if exists
		${If} "$AndroidStudioExists" == "true"
			${RunCmd} '"$FlutterDir\bin\flutter.bat" config --android-studio-dir="$AndroidStudioDir"'
		${EndIf}
	${EndIf}
!macroend

${SegmentPostPrimary}
	; Flutter telemetry config files
	Delete "$APPDATA\.flutter*"

	; Dart telemetry config files
	RMDir /r "$APPDATA\.dart"
	RMDir /r "$APPDATA\.dart-tool"

	; Dart analysis server files
	RMDir /r "$LOCALAPPDATA\.dartServer"
!macroend