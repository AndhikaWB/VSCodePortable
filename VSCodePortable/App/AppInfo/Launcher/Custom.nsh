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
Var RustDir

Var GitHome
Var PythonUser
Var NodePrefix
Var GolangPath
Var RustCargoHome
Var PlatformIOCore

${SegmentInit}
	; Define frequently accessed paths
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
	; PortableAppsDir is the parent folder of the launcher folder
	${SetEnvironmentVariablesPath} "PAL:PortableAppsDir" "$PortableAppsDirectory"
	${SetEnvironmentVariablesPath} "PAL:CommonFilesDir" "$PortableAppsDirectory\CommonFiles"

	; "PATH" on a clean installation of Windows 11 (see below)
	${SetEnvironmentVariablesPath} "__clean__" "$WINDIR\System32;$WINDIR;$WINDIR\System32\WindowsPowerShell\v1.0;$WINDIR\System32\OpenSSH"
!macroend

${SegmentPreExec}
	; Use custom "PATH" if provided in "VSCodePortable.ini"
	; You can use "PATH=%__clean__%" to emulate a clean installation
	${ReadUserConfig} "$BasePath" "PATH"
	; Read "PATH" environment variable (from system) if not defined
	${If} "$BasePath" == ""
		ReadEnvStr "$BasePath" "PATH"
	${EndIf}
	ExpandEnvStrings "$BasePath" "$BasePath"

	; Auto-detect some popular development environments
	; MSYS2 packages may have different folder structures!

	; Git
	${ReadUserConfig} "$GitDir" "GIT"
	ExpandEnvStrings "$GitDir" "$GitDir"
	${If} ${FileExists} "$GitDir\cmd\git.exe"
		; Change Git user's home directory (may affect MinGW and MSYS too)
		; Useful if you like to mod your Git setup (e.g. installing Oh My Zsh)
		; This will prevent config files from being saved to "%UserProfile%" folder
		${ReadUserConfig} "$GitHome" "ChangeGitHomePath"
		${If} "$GitHome" == "true"
			CreateDirectory "$DataDir\misc\GitHome"
			; The default is "%UserProfile%"
			${SetEnvironmentVariablesPath} "HOME" "$DataDir\misc\GitHome"
			; Also copy custom shell config files on first run (contains workaround for "cd" command)
			; These files may be overwritten by Oh My Zsh, so you may need to add "cd" alias at the end of file manually
			${IfNot} ${FileExists} "$DataDir\misc\GitHome\.bashrc"
				CopyFiles /Silent "$DefaultDataDir\misc\GitHome\.bashrc" "$DataDir\misc\GitHome"
			${EndIf}
			${IfNot} ${FileExists} "$DataDir\misc\GitHome\.zshrc"
				CopyFiles /Silent "$DefaultDataDir\misc\GitHome\.zshrc" "$DataDir\misc\GitHome"
			${EndIf}
		${EndIf}
		${If} ${FileExists} "$GitDir\post-install.bat"
			; Portable Git post installation
			; Cmd crazily remove quotes so nesting it will be needed
			nsExec::Exec '"$CmdPath" /C ""$GitDir\post-install.bat""'
		${EndIf}
		StrCpy "$ExtraPath" "$GitDir\cmd;$GitDir\usr\bin"
	${EndIf}

	; MinGW (GCC)
	${ReadUserConfig} "$MinGWDir" "MINGW"
	ExpandEnvStrings "$MinGWDir" "$MinGWDir"
	${If} ${FileExists} "$MinGWDir\bin\gcc.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$MinGWDir\bin"
	${EndIf}

	; Python
	${ReadUserConfig} "$PythonDir" "PYTHON"
	ExpandEnvStrings "$PythonDir" "$PythonDir"
	${If} ${FileExists} "$PythonDir\python.exe"
		${ReadUserConfig} "$PythonUser" "ChangePythonUserPath"
		${If} "$PythonUser" == "true"
			; Change Python user's base directory (the default is "%AppData%\Python")
			; Will not affect globally installed packages (local user packages only)
			${SetEnvironmentVariablesPath} "PYTHONUSERBASE" "$DataDir\misc\Python"
		${EndIf}
		; Get "scripts" directory and add it to "PATH"
		nsExec::ExecToStack '"$PythonDir\python.exe" -m site --user-site'
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

	; Node.js
	${ReadUserConfig} "$NodeJSDir" "NODEJS"
	ExpandEnvStrings "$NodeJSDir" "$NodeJSDir"
	${If} ${FileExists} "$NodeJSDir\node.exe"
		${ReadUserConfig} "$NodePrefix" "ChangeNodePrefixPath"
		${If} "$NodePrefix" == "true"
			; Force change Node.js user's prefix and cache path
			; If not changed, the default is "%AppData%\npm" and "%AppData%\npm-cache"
			; May be dangerous on shared computer, as it will write its config in "%UserProfile%\.npmrc"
			nsExec::Exec '"$CmdPath" /C ""$NodeJSDir\npm.cmd" config set prefix "$DataDir\misc\NodeJS""'
			nsExec::Exec '"$CmdPath" /C ""$NodeJSDir\npm.cmd" config set cache "$DataDir\misc\NodeJS\cache""'
		${EndIf}
		; Get prefix directory and add it to "PATH"
		nsExec::ExecToStack '"$CmdPath" /C ""$NodeJSDir\npm.cmd" config get prefix"'
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
		${ReadUserConfig} "$GolangPath" "ChangeGolangPath"
		${If} "$GolangPath" == "true"
			; Change Golang path aka "GOPATH" (where it stores user packages)
			; I think it's rarely used nowadays since Go introduced "modules"
			; The default is "%UserProfile%\Go"
			${SetEnvironmentVariablesPath} "GOPATH" "$DataDir\misc\Go"
			; Just in case there is an executable file(s)
			StrCpy "$ExtraPath" "$ExtraPath;$DataDir\misc\Go\bin"
		${EndIf}
	${EndIf}

	; Rust
	${ReadUserConfig} "$RustDir" "RUST"
	ExpandEnvStrings "$RustDir" "$RustDir"
	${If} ${FileExists} "$RustDir\bin\cargo.exe"
	${AndIf} ${FileExists} "$RustDir\bin\rustc.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$RustDir\bin"
		${ReadUserConfig} "$RustCargoHome" "ChangeRustCargoHome"
		${If} "$RustCargoHome" == "true"
			; Change Cargo (Rust package manager) home
			; The default is "%UserProfile%\.cargo"
			${SetEnvironmentVariablesPath} "CARGO_HOME" "$DataDir\misc\Rust\Cargo"
			; Just in case there is an executable file(s)
			StrCpy "$ExtraPath" "$ExtraPath;$DataDir\misc\Rust\Cargo\bin"
		${EndIf}
	${EndIf}

	; PlatformIO
	${ReadUserConfig} "$PlatformIOCore" "ChangePlatformIOCorePath"
	${If} "$PlatformIOCore" == "true"
		; Change PlatformIO core path (where it stores config files and SDKs)
		; The default is "%UserProfile%\.platformio"
		${SetEnvironmentVariablesPath} "PLATFORMIO_CORE_DIR" "$DataDir\misc\PlatformIO"
	${EndIf}

	; Prepend all valid environments onto the "PATH" environment variable
	; Modified "PATH" will only be read by VSCode and processes spawned by it
	; If "PATH" is longer than 8196 bytes, it will be reverted to default (NSIS restriction)

	StrLen $R1 "$ExtraPath_$BasePath_"
	IntOp $R1 $R1 * ${NSIS_CHAR_SIZE}
	${If} $R1 < ${NSIS_MAX_STRLEN}
		${SetEnvironmentVariablesPath} "PATH" "$ExtraPath;$BasePath"
	${Else}
		MessageBox MB_OK|MB_ICONEXCLAMATION 'The modified "PATH" environment variable is too long, reverting to default as workaround.'
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
			MessageBox MB_YESNO|MB_ICONQUESTION 'Do you want to install "$R2"? It may take a while, please be patient.' IDNO +2
			ExecWait '"$CmdPath" /C ""$AppDir\VSCode\bin\code.cmd" --install-extension "$DefaultDataDir\VSCode\extensions\$R2""'
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

	; Overwrite values written by VSCode at launch
	WriteRegStr HKCR "vscode\shell\open\command" "" '"$EXEPATH" --open-url -- "%1"'
	WriteRegStr HKCU "Software\Classes\vscode\shell\open\command" "" '"$EXEPATH" --open-url -- "%1"'

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

; You can also rename this segment to PostExecPrimary
; Patch the "PortableApps.comLauncher.nsi" file to allow custom code
; Uncomment the "${RunSegment} Custom" line if it isn't already

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
	RMDir /r "$APPDATA\jupyter"
	RMDir "$LOCALAPPDATA\pip"

	; Java related leftovers
	Delete "$PROFILE\.tooling\gradle\versions.json"
	RMDir "$PROFILE\.tooling\gradle"
	RMDir "$PROFILE\.tooling"

	; Node.js related leftovers
	Delete "$PROFILE\.config\configstore\update-notifier-npm.json"
	RMDir "$PROFILE\.config\configstore"
	RMDir "$PROFILE\.config"
	RMDir /r "$APPDATA\npm-cache\_logs"
	RMDir /r "$APPDATA\npm-cache"
	RMDir "$APPDATA\npm"

	; Golang related leftovers
	RMDir /r "$LOCALAPPDATA\go-build"
	RMDir /r "$LOCALAPPDATA\gopls"
	RMDir /r "$LOCALAPPDATA\staticcheck"

	; Rust related leftovers
	Delete "$PROFILE\.cargo\.package-cache"
	RMDir /r "$PROFILE\.cargo\registry"
	RMDir "$PROFILE\.cargo"
!macroend