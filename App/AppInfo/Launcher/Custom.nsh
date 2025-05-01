!include "${PACKAGE}\App\AppInfo\Launcher\Modules\*.nsh"

Var CmdPath

Var AppDir
Var VSCodeDataDir
Var DataDir
Var DefaultDataDir

Var BasePath
Var ExtraPath

${SegmentFile}

${SegmentInit}
	; Command prompt executable path
	ExpandEnvStrings "$CmdPath" "%COMSPEC%"

	; VS Code app directory
	StrCpy "$AppDir" "$EXEDIR\App"
	; VS Code data directory
	StrCpy "$VSCodeDataDir" "$EXEDIR\App\VSCode\data"
	; Launcher and other data directory (e.g. downloaded Python libraries)
	StrCpy "$DataDir" "$EXEDIR\Data"
	; Default directory for all initial data (used on the first run)
	StrCpy "$DefaultDataDir" "$EXEDIR\App\FirstRun"

	; Copy default "VSCodePortable.ini" (first run)
	${IfNot} ${FileExists} "$EXEDIR\$AppID.ini"
		CopyFiles /Silent "$DefaultDataDir\$AppID.ini" "$EXEDIR\$AppID.ini"
	${EndIf}

	; Copy default VS Code "user-data" folder (first run)
	CreateDirectory "$VSCodeDataDir"
	${IfNot} ${FileExists} "$VSCodeDataDir\user-data\*.*"
		CopyFiles /Silent "$DefaultDataDir\VSCode\user-data\*.*" "$VSCodeDataDir\user-data"
	${EndIf}

	; Install user provided VSIX files if exists (first run)
	${IfNot} ${FileExists} "$VSCodeDataDir\extensions\*.*"
		FindFirst $R1 $R2 "$DefaultDataDir\VSCode\extensions\*.vsix"
		CheckVsix:
		${If} $R2 != ""
			MessageBox MB_YESNO|MB_ICONQUESTION 'Do you want to install "$R2"? It may take a while, please be patient.' IDNO +2
			ExecWait '"$CmdPath" /C ""$AppDir\VSCode\bin\code.cmd" --install-extension "$DefaultDataDir\VSCode\extensions\$R2""'
			FindNext $R1 $R2
			Goto CheckVsix
		${EndIf}
		FindClose $R1
	${EndIf}

	; Create shortcut to VS Code "user-data" folder
	CreateDirectory "$DataDir"
	Delete "$DataDir\user-data.lnk"
	CreateShortCut "$DataDir\user-data.lnk" "$VSCodeDataDir\user-data"

	; Create shortcut to VS Code "extensions" folder
	Delete "$DataDir\extensions.lnk"
	CreateShortCut "$DataDir\extensions.lnk" "$VSCodeDataDir\extensions"
!macroend

${SegmentPre}
	; Set environment variables for launcher related directories
	${SetEnvironmentVariablesPath} "PAL:LauncherDir" "$EXEDIR"
	${SetEnvironmentVariablesPath} "PAL:LauncherPath" "$EXEPATH"
	${SetEnvironmentVariablesPath} "PAL:LauncherFile" "$EXEFILE"

	; PortableAppsDir is the parent directory of the launcher directory
	; CommonFilesDir can be used to store development environment binaries (e.g. Python)
	${SetEnvironmentVariablesPath} "PAL:PortableAppsDir" "$PortableAppsDirectory"
	${SetEnvironmentVariablesPath} "PAL:CommonFilesDir" "$PortableAppsDirectory\CommonFiles"

	; Example "PATH" from a clean installation of Windows 11
	; Can be used to override system "PATH" if it's too long (see below)
	${SetEnvironmentVariablesPath} "__clean__" "$WINDIR\System32;$WINDIR;$WINDIR\System32\WindowsPowerShell\v1.0;$WINDIR\System32\OpenSSH"
!macroend

${SegmentPreExec}
	; Override system "PATH" if provided in "VSCodePortable.ini"
	; You can use "PATH=%__clean__%" to emulate a clean Windows installation
	${ReadUserConfig} "$BasePath" "OverridePath"

	; Read "PATH" from the system if not defined
	${If} "$BasePath" == ""
		ReadEnvStr "$BasePath" "PATH"
	${EndIf}

	; Always expand environment variables on "PATH"
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
	; Modified "PATH" will only affect VS Code and all processes spawned by VS Code
	; If the "PATH" is longer than 8196 bytes, it will be reverted to default (NSIS limitation)
	StrLen $R1 "$ExtraPath_$BasePath_"
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