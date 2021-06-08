${SegmentFile}

Var AppDir
Var DataDir
Var DefaultDataDir
Var VSCodeDataDir

Var CmdPath
Var BasePath
Var ExtraPath

Var GitDir
Var MinGWDir
Var PythonDir
Var JavaDir
Var NodeJSDir
Var GolangDir

${SegmentInit}
	; Set internal user variables
	StrCpy "$AppDir" "$EXEDIR\App"
	StrCpy "$DataDir" "$EXEDIR\Data"
	StrCpy "$VSCodeDataDir" "$EXEDIR\App\VSCode\data"
	StrCpy "$DefaultDataDir" "$EXEDIR\App\FirstRun"
	ExpandEnvStrings "$CmdPath" "%COMSPEC%"

	; Copy "VSCodePortable.ini" file
	${IfNot} ${FileExists} "$EXEDIR\$AppID.ini"
		CopyFiles /Silent "$DefaultDataDir\$AppID.ini" "$EXEDIR\$AppID.ini"
	${EndIf}
!macroend

${SegmentPre}
	; Set custom environment variables
	${SetEnvironmentVariablesPath} "PAL:LauncherDir" "$EXEDIR"
	${SetEnvironmentVariablesPath} "PAL:LauncherPath" "$EXEPATH"
	${SetEnvironmentVariablesPath} "PAL:LauncherFile" "$EXEFILE"
	${SetEnvironmentVariablesPath} "PAL:PortableAppsDir" "$PortableAppsDirectory"
	${SetEnvironmentVariablesPath} "PAL:CommonFilesDir" "$PortableAppsDirectory\CommonFiles"
!macroend

${SegmentPreExec}
	; Read "PATH" environment variable
	${ReadUserConfig} "$BasePath" "PATH"
	${If} "$BasePath" == ""
		ReadEnvStr "$BasePath" "PATH"
	${ElseIf} "$BasePath" == "__clean__"
		ReadEnvStr "$BasePath" "$WINDIR\System32;$WINDIR;$WINDIR\System32\Wbem;$WINDIR\System32\WindowsPowerShell\v1.0\"
	${EndIf}
	ExpandEnvStrings "$BasePath" "$BasePath"

	; Supported development environments
	; Please be aware when using MSYS2 packages
	; They may have unsupported folder structures

	${ReadUserConfig} "$GitDir" "GIT"
	ExpandEnvStrings "$GitDir" "$GitDir"
	${If} ${FileExists} "$GitDir\cmd\git.exe"
		${If} ${FileExists} "$GitDir\post-install.bat"
			nsExec::Exec "$\"$CmdPath$\" /C $\"$\"$GitDir\post-install.bat$\"$\""
		${EndIf}
		StrCpy "$ExtraPath" "$GitDir\cmd;$GitDir\usr\bin"
	${EndIf}

	${ReadUserConfig} "$MinGWDir" "MINGW"
	ExpandEnvStrings "$MinGWDir" "$MinGWDir"
	${If} ${FileExists} "$MinGWDir\bin\gcc.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$MinGWDir\bin"
	${EndIf}

	; For portability reason, do not install Python module per user
	; Use "Global Module Installation" instead when using Python extension
	; This is already set by default, go to settings to revert it

	${ReadUserConfig} "$PythonDir" "PYTHON"
	ExpandEnvStrings "$PythonDir" "$PythonDir"
	${If} ${FileExists} "$PythonDir\python.exe"
		nsExec::ExecToStack "$\"$PythonDir\python.exe$\" -m site --user-site"
		Pop $R1
		${If} $R1 == 0
			Pop $R2
			${GetParent} $R2 $R2
			StrCpy "$ExtraPath" "$ExtraPath;$PythonDir;$PythonDir\scripts;$R2\scripts"
		${Else}
			StrCpy "$ExtraPath" "$ExtraPath;$PythonDir;$PythonDir\scripts"
		${EndIf}
		ExpandEnvStrings $R3 "%PYTHONPATH%"
		${If} $R3 == ""
			${SetEnvironmentVariablesPath} "PYTHONPATH" "$PythonDir\lib;$PythonDir\dlls"
		${Else}
			${SetEnvironmentVariablesPath} "PYTHONPATH" "$PythonDir\lib;$PythonDir\dlls;$R3"
		${EndIf}
	${EndIf}

	${ReadUserConfig} "$JavaDir" "JAVA"
	ExpandEnvStrings "$JavaDir" "$JavaDir"
	${If} ${FileExists} "$JavaDir\bin\java.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$JavaDir\bin"
		${SetEnvironmentVariablesPath} "JAVA_HOME" "$JavaDir"
	${EndIf}

	; For portability reason, "prefix" and "cache" path must be changed beforehand
	; You can either edit "npmrc" file directly or use "npm config set" command
	; Why not automate it? Many people use non-portable Node.js already

	${ReadUserConfig} "$NodeJSDir" "NODEJS"
	ExpandEnvStrings "$NodeJSDir" "$NodeJSDir"
	${If} ${FileExists} "$NodeJSDir\node.exe"
		nsExec::ExecToStack "$\"$CmdPath$\" /C $\"$\"$NodeJSDir\npm.cmd$\"$\" config get prefix"
		Pop $R1
		${If} $R1 == 0
			Pop $R2
			StrCpy "$ExtraPath" "$ExtraPath;$NodeJSDir;$R2"
		${Else}
			StrCpy "$ExtraPath" "$ExtraPath;$NodeJSDir"
		${EndIf}
	${EndIf}

	${ReadUserConfig} "$GolangDir" "GOLANG"
	ExpandEnvStrings "$GolangDir" "$GolangDir"
	${If} ${FileExists} "$GolangDir\bin\go.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$GolangDir\bin"
		${SetEnvironmentVariablesPath} "GOPATH" "$GolangDir"
	${EndIf}

	; Prepend all valid environments onto the "PATH" environment variable
	; Modified "PATH" will only be read by VSCode and its spawned processes
	; "PATH" longer than 8196 bytes will be reverted to default

	StrLen $R1 "$ExtraPath_$BasePath_"
	IntOp $R1 $R1 * ${NSIS_CHAR_SIZE}
	${If} $R1 < ${NSIS_MAX_STRLEN}
		${SetEnvironmentVariablesPath} "PATH" "$ExtraPath;$BasePath"
	${Else}
		MessageBox MB_OK|MB_ICONEXCLAMATION "The modified $\"PATH$\" environment variable is too long, reverting to default as workaround."
	${EndIf}

	; Copy "user-data" folder
	CreateDirectory "$VSCodeDataDir"
	${IfNot} ${FileExists} "$VSCodeDataDir\user-data\*.*"
		CopyFiles /Silent "$DefaultDataDir\VSCode\user-data\*.*" "$VSCodeDataDir\user-data"
	${EndIf}

	; Install VSIX files to "extensions" folder
	${IfNot} ${FileExists} "$VSCodeDataDir\extensions\*.*"
		FindFirst $R1 $R2 "$DefaultDataDir\VSCode\extensions\*.vsix"
		CheckFile:
		${If} $R2 != ""
			MessageBox MB_YESNO|MB_ICONQUESTION "Do you want to install $\"$R2$\"? It may take a while, please be patient." IDNO +2
			ExecWait "$\"$CmdPath$\" /C $\"$\"$AppDir\VSCode\bin\code.cmd$\" --install-extension $\"$DefaultDataDir\VSCode\extensions\$R2$\"$\""
			FindNext $R1 $R2
			Goto CheckFile
		${EndIf}
		FindClose $R1
	${EndIf}

	; Create shortcuts to "user-data" folder
	CreateDirectory "$DataDir"
	Delete "$DataDir\user-data.lnk"
	CreateShortCut "$DataDir\user-data.lnk" "$VSCodeDataDir\user-data"

	; Create shortcuts to "extensions" folder
	Delete "$DataDir\extensions.lnk"
	CreateShortCut "$DataDir\extensions.lnk" "$VSCodeDataDir\extensions"
!macroend

/*
${OverrideExecute}
	Exec "$ExecString"
	Sleep 5000

	; Overwrite values written by VSCode at launch
	WriteRegStr HKCR "vscode\shell\open\command" "" "$\"$EXEPATH$\" --open-url -- $\"%1$\""
	WriteRegStr HKCU "Software\Classes\vscode\shell\open\command" "" "$\"$EXEPATH$\" --open-url -- $\"%1$\""

	CheckProcess:
	${If} ${ProcessExists} "Code.exe"
		${GetProcessPath} "Code.exe" $R1
		${If} $R1 == "$AppDir\VSCode\Code.exe"
			Sleep 1000
			Goto CheckProcess
		${EndIf}
	${EndIf}
!macroend
*/

${SegmentPostPrimary}
	; PAF installer related leftovers
	Delete "$AppDir\AppInfo\pac_installer_log.ini"
	RMDir /r "$DataDir\PortableApps.comInstaller"
	RMDir "$EXEDIR\Other\Source"

	; Live Share related leftovers
	DeleteRegKey HKCR "vsls"
	DeleteRegKey HKCR "code.launcher.handler"
	DeleteRegKey HKCU "Software\Classes\vsls"
	DeleteRegKey HKCU "Software\Classes\code.launcher.handler"
	DeleteRegKey HKCU "Software\code.launcher"
	DeleteRegValue HKCU "Software\RegisteredApplications" "code.launcher"

	; C/C++ related leftovers
	RMDir /r "$LOCALAPPDATA\Microsoft\vscode-cpptools"

	; Python related leftovers
	RMDir /r "$PROFILE\.pylint.d"
	RMDir /r "$LOCALAPPDATA\Jedi"
	RMDir "$LOCALAPPDATA\pip\cache"
	RMDir "$LOCALAPPDATA\pip"

	; Java related leftovers
	Delete "$PROFILE\.tooling\gradle\versions.json"
	RMDir "$PROFILE\.tooling\gradle"
	RMDir "$PROFILE\.tooling"

	; Node.js related leftovers
	Delete "$PROFILE\.config\configstore\update-notifier-npm.json"
	RMDir "$PROFILE\.config\configstore"
	RMDir "$PROFILE\.config"
	RMDir "$APPDATA\npm-cache"
	RMDir "$APPDATA\npm"
!macroend