; Please recompile the launcher to apply changes made in this file
; https://portableapps.com/apps/development/portableapps.com_launcher

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
	; Define various paths (hard code only)
	; Will not be added as environment variables
	StrCpy "$AppDir" "$EXEDIR\App"
	StrCpy "$DataDir" "$EXEDIR\Data"
	StrCpy "$DefaultDataDir" "$EXEDIR\App\FirstRun"
	StrCpy "$VSCodeDataDir" "$EXEDIR\App\VSCode\data"
	ExpandEnvStrings "$CmdPath" "%COMSPEC%"

	; Copy "VSCodePortable.ini" (first run)
	${IfNot} ${FileExists} "$EXEDIR\$AppID.ini"
		CopyFiles /Silent "$DefaultDataDir\$AppID.ini" "$EXEDIR\$AppID.ini"
	${EndIf}
!macroend

${SegmentPre}
	; Set custom environment variable for launcher related directories
	${SetEnvironmentVariablesPath} "PAL:LauncherDir" "$EXEDIR"
	${SetEnvironmentVariablesPath} "PAL:LauncherPath" "$EXEPATH"
	${SetEnvironmentVariablesPath} "PAL:LauncherFile" "$EXEFILE"
	${SetEnvironmentVariablesPath} "PAL:PortableAppsDir" "$PortableAppsDirectory"
	${SetEnvironmentVariablesPath} "PAL:CommonFilesDir" "$PortableAppsDirectory\CommonFiles"
!macroend

${SegmentPreExec}
	; Use custom "PATH" if provided in "VSCodePortable.ini"
	${ReadUserConfig} "$BasePath" "PATH"
	; Read "PATH" environment variable (from system) if not defined
	${If} "$BasePath" == ""
		ReadEnvStr "$BasePath" "PATH"
	${ElseIf} "$BasePath" == "__clean__"
		; Use "PATH=__clean__" to emulate clean Windows 11 installation
		ReadEnvStr "$BasePath" "$WINDIR\System32;$WINDIR;$WINDIR\System32\WindowsPowerShell\v1.0\;$WINDIR\System32\OpenSSH\"
	${EndIf}
	ExpandEnvStrings "$BasePath" "$BasePath"

	; Auto-detect some popular development environments
	; MSYS2 packages may have different folder structures!

	; Git
	${ReadUserConfig} "$GitDir" "GIT"
	ExpandEnvStrings "$GitDir" "$GitDir"
	${If} ${FileExists} "$GitDir\cmd\git.exe"
		; Change Git home directory (can be annoying but good for portability)
		; You can workaround this by replacing cd with an alias (in .bashrc and .zshrc)
		; Those files will automatically be set on first run, no need to do anything
		CreateDirectory "$DataDir\misc\GitHome"
		${SetEnvironmentVariablesPath} "HOME" "$DataDir\misc\GitHome"
		${If} ${FileExists} "$GitDir\post-install.bat"
			; Portable Git post installation
			nsExec::Exec "$\"$CmdPath$\" /C $\"$\"$GitDir\post-install.bat$\"$\""
		${EndIf}
		StrCpy "$ExtraPath" "$GitDir\cmd;$GitDir\usr\bin"
	${EndIf}

	; MinGW (GCC)
	${ReadUserConfig} "$MinGWDir" "MINGW"
	ExpandEnvStrings "$MinGWDir" "$MinGWDir"
	${If} ${FileExists} "$MinGWDir\bin\gcc.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$MinGWDir\bin"
	${EndIf}

	; Python user packages will be installed in "Data\misc\Python" folder
	; Packages installed globally are not affected by "PYTHONUSERBASE"
	; Don't forget to recompile the launcher in case you reverted it

	; Python
	${ReadUserConfig} "$PythonDir" "PYTHON"
	ExpandEnvStrings "$PythonDir" "$PythonDir"
	${If} ${FileExists} "$PythonDir\python.exe"
		; Change user base directory (for portability)
		${SetEnvironmentVariablesPath} "PYTHONUSERBASE" "$DataDir\misc\Python"
		; Get "scripts" directory and add it to "PATH"
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

	; Java (JRE/JDK)
	${ReadUserConfig} "$JavaDir" "JAVA"
	ExpandEnvStrings "$JavaDir" "$JavaDir"
	${If} ${FileExists} "$JavaDir\bin\java.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$JavaDir\bin"
		${SetEnvironmentVariablesPath} "JAVA_HOME" "$JavaDir"
	${EndIf}

	; For portable usage, you need to change Node.js "prefix" and "cache" path manually
	; Please edit "npmrc" file or simply use "npm config set XXX YYY" command
	; Feel free to open a pull request if you want to automate it
	; No need to change anything if you don't need portability

	; Node.js
	${ReadUserConfig} "$NodeJSDir" "NODEJS"
	ExpandEnvStrings "$NodeJSDir" "$NodeJSDir"
	${If} ${FileExists} "$NodeJSDir\node.exe"
		; Get prefix directory and add it to "PATH"
		nsExec::ExecToStack "$\"$CmdPath$\" /C $\"$\"$NodeJSDir\npm.cmd$\"$\" config get prefix"
		Pop $R1
		${If} $R1 == 0
			Pop $R2
			StrCpy "$ExtraPath" "$ExtraPath;$NodeJSDir;$R2"
		${Else}
			StrCpy "$ExtraPath" "$ExtraPath;$NodeJSDir"
		${EndIf}
	${EndIf}

	; Golang
	${ReadUserConfig} "$GolangDir" "GOLANG"
	ExpandEnvStrings "$GolangDir" "$GolangDir"
	${If} ${FileExists} "$GolangDir\bin\go.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$GolangDir\bin"
		${SetEnvironmentVariablesPath} "GOPATH" "$GolangDir"
	${EndIf}

	; Prepend all valid environments onto the "PATH" environment variable
	; Modified "PATH" will only be read by VSCode and processes spawned by it
	; If "PATH" is longer than 8196 bytes, it will be reverted to default (NSIS restriction)

	StrLen $R1 "$ExtraPath_$BasePath_"
	IntOp $R1 $R1 * ${NSIS_CHAR_SIZE}
	${If} $R1 < ${NSIS_MAX_STRLEN}
		${SetEnvironmentVariablesPath} "PATH" "$ExtraPath;$BasePath"
	${Else}
		MessageBox MB_OK|MB_ICONEXCLAMATION "The modified $\"PATH$\" environment variable is too long, reverting to default as workaround."
	${EndIf}

	; Copy Git home config files (first run)
	${IfNot} ${FileExists} "$DataDir\misc\GitHome\.bashrc"
		CopyFiles /Silent "$DefaultDataDir\misc\GitHome\.bashrc" "$DataDir\misc\GitHome"
	${EndIf}
	${IfNot} ${FileExists} "$DataDir\misc\GitHome\.zshrc"
		CopyFiles /Silent "$DefaultDataDir\misc\GitHome\.zshrc" "$DataDir\misc\GitHome"
	${EndIf}

	; Copy default "user-data" folder (first run)
	CreateDirectory "$VSCodeDataDir"
	${IfNot} ${FileExists} "$VSCodeDataDir\user-data\*.*"
		CopyFiles /Silent "$DefaultDataDir\VSCode\user-data\*.*" "$VSCodeDataDir\user-data"
	${EndIf}

	; Install bundled VSIX files to "extensions" folder (first run)
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

	; Create shortcut to "user-data" folder
	CreateDirectory "$DataDir"
	Delete "$DataDir\user-data.lnk"
	CreateShortCut "$DataDir\user-data.lnk" "$VSCodeDataDir\user-data"

	; Create shortcut to "extensions" folder
	Delete "$DataDir\extensions.lnk"
	CreateShortCut "$DataDir\extensions.lnk" "$VSCodeDataDir\extensions"
!macroend

/*
${OverrideExecute}
	Exec "$ExecString"
	Sleep 5000

	; Overwrite values written by VSCode on launch
	WriteRegStr HKCR "vscode\shell\open\command" "" "$\"$EXEPATH$\" --open-url -- $\"%1$\""
	WriteRegStr HKCU "Software\Classes\vscode\shell\open\command" "" "$\"$EXEPATH$\" --open-url -- $\"%1$\""

	CheckRunning:
	${If} ${ProcessExists} "Code.exe"
		${GetProcessPath} "Code.exe" $R1
		${If} $R1 == "$AppDir\VSCode\Code.exe"
			Sleep 1000
			Goto CheckRunning
		${EndIf}
	${EndIf}
!macroend
*/

${SegmentPostPrimary}
	; RMDir: delete the folder only if it is empty
	; RMDir /r: recursively delete the folder and everything inside it

	; Live Share related leftovers
	DeleteRegKey HKCR "vsls"
	DeleteRegKey HKCR "code.launcher.handler"
	DeleteRegKey HKCU "Software\Classes\vsls"
	DeleteRegKey HKCU "Software\Classes\code.launcher.handler"
	DeleteRegKey HKCU "Software\code.launcher"
	DeleteRegValue HKCU "Software\RegisteredApplications" "code.launcher"
	RMDir /r "$LOCALAPPDATA\IsolatedStorage"

	; C/C++ related leftovers
	RMDir /r "$LOCALAPPDATA\Microsoft\vscode-cpptools"

	; Python related leftovers
	RMDir /r "$PROFILE\.pylint.d"
	RMDir /r "$PROFILE\.ipython"
	RMDir /r "$PROFILE\.matplotlib"
	RMDir /r "$LOCALAPPDATA\Jedi"
	RMDir /r "$LOCALAPPDATA\pip\cache"
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