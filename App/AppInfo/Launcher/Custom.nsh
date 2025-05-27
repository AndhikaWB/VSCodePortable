!include "${PACKAGE}\App\AppInfo\Launcher\Modules\*.nsh"

Var AppDir
Var DataDir
Var FirstRunDir
Var IsFirstRun

Var CmdPath
Var BasePath
Var ExtraPath

${SegmentFile}

${SegmentInit}
	; Shortcut to command prompt executable
	ExpandEnvStrings "$CmdPath" "%COMSPEC%"

	; Shortcut to launcher related paths
	StrCpy "$AppDir" "$EXEDIR\App"
	StrCpy "$DataDir" "$EXEDIR\Data"
	StrCpy "$FirstRunDir" "$EXEDIR\App\FirstRun"

	${IfNot} ${FileExists} "$DataDir\settings\VSCodePortable*.ini"
		StrCpy "$IsFirstRun" "true"
	${EndIf}
!macroend

${SegmentPrePrimary}
	${If} "$IsFirstRun" == "true"
		; Copy launcher config
		CreateDirectory "$DataDir\settings"
		CopyFiles "$FirstRunDir\settings\Custom.ini" "$DataDir\settings\Custom.ini"

		; Copy default user config
		CreateDirectory "$AppDir\VSCode\data\user-data"
		CopyFiles "$FirstRunDir\VSCode\user-data\*.*" "$AppDir\VSCode\data\user-data"

		; Install user provided VSIX files
		FindFirst $R1 $R2 "$FirstRunDir\VSCode\extensions\*.vsix"
		CheckVsix:
		${If} $R2 != ""
			MessageBox MB_YESNO|MB_ICONQUESTION 'Do you want to install "$R2"? It may take a while, please be patient.' IDNO +2
			ExecWait '"$CmdPath" /C ""$AppDir\VSCode\bin\code.cmd" --install-extension "$FirstRunDir\VSCode\extensions\$R2""'
			FindNext $R1 $R2
			Goto CheckVsix
		${EndIf}
		FindClose $R1
	${EndIf}

	${CreateShortcut} "$DataDir\user-data.lnk" "$AppDir\VSCode\data\user-data"
	${CreateShortcut} "$DataDir\extensions.lnk" "$AppDir\VSCode\data\extensions"
!macroend

${SegmentPre}
	; Full path to launcher directory
	${SetEnvironmentVariablesPath} "PAL:LauncherDir" "$EXEDIR"
	; Full path to launcher executable
	${SetEnvironmentVariablesPath} "PAL:LauncherPath" "$EXEPATH"

	; Parent directory of the launcher directory
	${SetEnvironmentVariablesPath} "PAL:PortableAppsDir" "$PortableAppsDirectory"
	; Directory for storing development environment binaries (e.g. Python, Node.js)
	${SetEnvironmentVariablesPath} "PAL:CommonFilesDir" "$PortableAppsDirectory\CommonFiles"
!macroend

${SegmentPreExec}
	; Override system "PATH" if provided in "Custom.ini" file
	${ReadCustomConfig} "$BasePath" "Path" "Base" "%PATH%"
	; Expand all environment variables on "PATH"
	ExpandEnvStrings "$BasePath" "$BasePath"
	; Initial value to be added to "PATH"
	StrCpy "$ExtraPath" ""

	; Custom modules
	${RunModule} Git
	${RunModule} MinGW
	${RunModule} Java
	${RunModule} Python
	${RunModule} R
	${RunModule} NodeJS
	${RunModule} Bun
	${RunModule} Go
	${RunModule} Rust
	${RunModule} Android
	${RunModule} Flutter
	${RunModule} PlatformIO

	; Prepend all valid environments onto the "PATH" environment variable
	; Modified "PATH" will only affect VS Code and all subprocesses spawned by VS Code
	; If the "PATH" is longer than 8196 bytes, it will be reverted to default (NSIS limitation)
	StrLen $R1 "$ExtraPath;$BasePath"
	IntOp $R1 $R1 * ${NSIS_CHAR_SIZE}
	${If} $R1 < ${NSIS_MAX_STRLEN}
		${SetEnvironmentVariablesPath} "PATH" "$ExtraPath;$BasePath"
	${Else}
		MessageBox MB_OK|MB_ICONEXCLAMATION 'The modified "PATH" environment variable is too long, reverted to default "PATH".'
	${EndIf}
!macroend

${SegmentPostPrimary}
	; Custom modules
	${RunModule} Git
	${RunModule} MinGW
	${RunModule} Java
	${RunModule} Python
	${RunModule} R
	${RunModule} NodeJS
	${RunModule} Bun
	${RunModule} Go
	${RunModule} Rust
	${RunModule} Android
	${RunModule} Flutter
	${RunModule} PlatformIO
!macroend