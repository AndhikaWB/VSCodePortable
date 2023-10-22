; Please recompile the launcher to apply changes made in this file
; https://portableapps.com/apps/development/portableapps.com_launcher

${SegmentFile}

Var AppDir
Var DataDir
Var DefaultDataDir
Var VSCodeDataDir

Var BasePath
Var ExtraPath

Var CmdPath
Var PythonPath

Var GitDir
Var MinGWDir
Var PythonDir
Var JavaDir
Var NodeJSDir
Var GolangDir
Var RustDir
Var AndroidStudioDir
Var AndroidStudioExist
Var AndroidSdkDir
Var FlutterDir
Var SparkDir

Var GitHome
Var PythonUser
Var NodePrefix
Var GolangPath
Var RustCargoHome
Var AndroidUser
Var AndroidGoogle
Var DartPubCache
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
			CreateDirectory "$DataDir\misc\Git\home"
			; If not set, the default is "%UserProfile%"
			${SetEnvironmentVariablesPath} "HOME" "$DataDir\misc\Git\home"
			; Also copy custom shell config files on first run (contains workaround for "cd" command)
			; These files may be overwritten by Oh My Zsh, so you may need to re-add the "cd" alias manually
			${IfNot} ${FileExists} "$DataDir\misc\Git\home\.bashrc"
				CopyFiles /Silent "$DefaultDataDir\misc\Git\home\.bashrc" "$DataDir\misc\Git\home"
			${EndIf}
			${IfNot} ${FileExists} "$DataDir\misc\Git\home\.zshrc"
				CopyFiles /Silent "$DefaultDataDir\misc\Git\home\.zshrc" "$DataDir\misc\Git\home"
			${EndIf}
		${EndIf}
		${If} ${FileExists} "$GitDir\post-install.bat"
			; Portable Git post installation
			; Cmd crazily remove quotes so nesting it will be needed
			nsExec::Exec '"$CmdPath" /C ""$GitDir\post-install.bat""'
		${EndIf}
		; Initial value to be added to "PATH"
		StrCpy "$ExtraPath" "$GitDir\bin;$GitDir\cmd"
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
		; Get user "scripts" directory and add it to "PATH"
		nsExec::ExecToStack '"$PythonDir\python.exe" -m site --user-site'
		Pop $R1
		${If} $R1 == 0
			Pop $R2
			${GetParent} $R2 $R2
			StrCpy "$ExtraPath" "$ExtraPath;$PythonDir;$PythonDir\scripts;$R2\scripts"
		${Else}
			StrCpy "$ExtraPath" "$ExtraPath;$PythonDir;$PythonDir\scripts"
		${EndIf}
		ExpandEnvStrings "$PythonPath" "%PYTHONPATH%"
		${If} "$PythonPath" == ""
			StrCpy "$PythonPath" "$PythonDir\lib;$PythonDir\dlls"
		${Else}
			StrCpy "$PythonPath" "$PythonDir\lib;$PythonDir\dlls;$PythonPath"
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
			; May be dangerous on shared computer, as it will write its config to "%UserProfile%\.npmrc"
			nsExec::Exec '"$CmdPath" /C ""$NodeJSDir\npm.cmd" config set prefix "$DataDir\misc\Node.js\npm""'
			nsExec::Exec '"$CmdPath" /C ""$NodeJSDir\npm.cmd" config set cache "$DataDir\misc\Node.js\npm-cache""'
		${EndIf}
		; Get prefix directory and add it to "PATH"
		nsExec::ExecToStack '"$CmdPath" /C ""$NodeJSDir\npm.cmd" config get prefix"'
		Pop $R1
		${If} $R1 == 0
			Pop $R2
			; Trim trailing newline from npm output
			; This will break cmd if left untouched
			${TrimNewLines} $R2 $R2
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
			; It's rarely used nowadays since Go introduced "modules"
			; The default is "%UserProfile%\Go"
			${SetEnvironmentVariablesPath} "GOPATH" "$DataDir\misc\Go"
			; Just in case there is an executable file(s)
			StrCpy "$ExtraPath" "$ExtraPath;$DataDir\misc\Go\bin"
		${EndIf}
	${EndIf}

	; Rust
	${ReadUserConfig} "$RustDir" "RUST"
	ExpandEnvStrings "$RustDir" "$RustDir"
	; Based on the standalone version, not using Rustup
	; For issue regarding rust-src, see the solution from link below
	; https://github.com/rust-lang/rust-analyzer/issues/4172#issuecomment-1664348160
	${If} ${FileExists} "$RustDir\bin\cargo.exe"
	${AndIf} ${FileExists} "$RustDir\bin\rustc.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$RustDir\bin"
		${ReadUserConfig} "$RustCargoHome" "ChangeRustCargoHome"
		${If} "$RustCargoHome" == "true"
			; Change Cargo (Rust package manager) home
			; The default is "%UserProfile%\.cargo"
			${SetEnvironmentVariablesPath} "CARGO_HOME" "$DataDir\misc\Rust\.cargo"
			; Just in case there is an executable file(s)
			StrCpy "$ExtraPath" "$ExtraPath;$DataDir\misc\Rust\.cargo\bin"
		${EndIf}
	${EndIf}

	; Android Studio/SDK behavior is buggy, at least on Windows
	; It will ignore environment variables so simple portablization attempt will not work
	; https://stackoverflow.com/questions/28777414/how-to-get-android-studio-to-not-use-default-folders
	; https://github.com/portapps/android-studio-portable/blob/master/main.go

	; As a quick and dirty workaround, junction/symlink will also be created (NTFS only, won't work on FAT)
	; If you want to use Android Studio Portable (by PortApps), empty the "ANDROID_SDK" path on "VSCodePortable.ini"
	; Otherwise, the created junction/symlink may cause undesirable behavior
	; Junction/symlink won't replace a folder if it already exist, though

	; Android Studio
	${ReadUserConfig} "$AndroidStudioDir" "ANDROID_STUDIO"
	ExpandEnvStrings "$AndroidStudioDir" "$AndroidStudioDir"
	${If} ${FileExists} "$AndroidStudioDir\bin\studio*.exe"
		; Add Android Studio to "PATH"
		StrCpy "$ExtraPath" "$ExtraPath;$AndroidStudioDir\bin"
		StrCpy "$AndroidStudioExist" "true"
		; Move Android Studio config folder location
		; The default is "Google\AndroidStudio*" in "%AppData%" and "%LocalAppData%"
		${ReadUserConfig} "$AndroidGoogle" "ChangeAndroidStudioConfig"
		${If} "$AndroidGoogle" == "true"
			; Create junction/symlink for Android Studio config folder
			CreateDirectory "$DataDir\misc\Android\Google\Local"
			nsExec::Exec '"$CmdPath" /C "mklink /J "$LOCALAPPDATA\Google" "$DataDir\misc\Android\Google\Local""'
			CreateDirectory "$DataDir\misc\Android\Google\Roaming"
			nsExec::Exec '"$CmdPath" /C "mklink /J "$APPDATA\Google" "$DataDir\misc\Android\Google\Roaming""'
		${EndIf}
	${EndIf}

	; Android SDK (see known issue from comments above)
	${ReadUserConfig} "$AndroidSdkDir" "ANDROID_SDK"
	ExpandEnvStrings "$AndroidSdkDir" "$AndroidSdkDir"
	; SDK must already exist if using standalone SDK
	; Can be downloaded later if using Android Studio
	${If} ${FileExists} "$AndroidSdkDir\*.*"
	${OrIf} "$AndroidStudioExist" == "true"
		${If} "$AndroidSdkDir" != ""
			; Create SDK directory if using Android Studio
			CreateDirectory "$AndroidSdkDir"
			; Set Android SDK path
			; https://developer.android.com/tools/variables
			${SetEnvironmentVariablesPath} "ANDROID_HOME" "$AndroidSdkDir"
			StrCpy "$ExtraPath" "$ExtraPath;$AndroidSdkDir\tools;$AndroidSdkDir\tools\bin;$AndroidSdkDir\platform-tools"
			; Create junction/symlink for Android SDK
			CreateDirectory "$LOCALAPPDATA\Android"
			nsExec::Exec '"$CmdPath" /C "mklink /J "$LOCALAPPDATA\Android\Sdk" "$AndroidSdkDir""'
			; Move Android related folders from "%UserProfile%" to "Data\misc\Android"
			${ReadUserConfig} "$AndroidUser" "ChangeAndroidUserPath"
			${If} "$AndroidUser" == "true"
				${SetEnvironmentVariablesPath} "ANDROID_USER_HOME" "$DataDir\misc\Android\.android"
				${SetEnvironmentVariablesPath} "GRADLE_USER_HOME" "$DataDir\misc\Android\.gradle"
				; Create junction/symlink for above directories
				CreateDirectory "$DataDir\misc\Android\.android"
				nsExec::Exec '"$CmdPath" /C "mklink /J "$PROFILE\.android" "$DataDir\misc\Android\.android""'
				CreateDirectory "$DataDir\misc\Android\.gradle"
				nsExec::Exec '"$CmdPath" /C "mklink /J "$PROFILE\.gradle" "$DataDir\misc\Android\.gradle""'
			${EndIf}
		${EndIf}
	${EndIf}

	; Flutter (Dart)
	${ReadUserConfig} "$FlutterDir" "FLUTTER"
	ExpandEnvStrings "$FlutterDir" "$FlutterDir"
	; Just check for Dart as Flutter uses it too
	${If} ${FileExists} "$FlutterDir\bin\dart*"
		StrCpy "$ExtraPath" "$ExtraPath;$FlutterDir\bin"
		; Disable telemetry and analytics (may not work if there's no Git)
		; Execute these commands directly on VS Code terminal just to be sure
		nsExec::Exec '"$CmdPath" /C ""$FlutterDir\flutter" config --no-analytics"'
		nsExec::Exec '"$CmdPath" /C ""$FlutterDir\flutter" --disable-telemetry"'
		nsExec::Exec '"$CmdPath" /C ""$FlutterDir\dart" --disable-analytics"'
		nsExec::Exec '"$CmdPath" /C ""$FlutterDir\dart" --disable-telemetry"'
		; Use our own Git instead of Flutter built-in Git
		; Removing it will save at least 150 MB of space
		RMDir /r "$FlutterDir\bin\mingit"
		; Also configure Android Studio path if exist
		${If} "$AndroidStudioExist" == "true"
			nsExec::Exec '"$CmdPath" /C ""$FlutterDir\flutter" config --android-studio-dir="$AndroidStudioDir""'
		${EndIf}
		; Package manager
		${ReadUserConfig} "$DartPubCache" "ChangeDartPubCache"
		${If} "$DartPubCache" == "true"
			; Change Dart Pub (package manager) cache location
			; The default is "%LocalAppData%\Pub\Cache"
			${SetEnvironmentVariablesPath} "PUB_CACHE" "$DataDir\misc\Dart\Pub\Cache"
		${EndIf}
	${EndIf}

	; Apache Spark
	${ReadUserConfig} "$SparkDir" "SPARK"
	ExpandEnvStrings "$SparkDir" "$SparkDir"
	${If} ${FileExists} "$SparkDir\bin\spark-shell*"
		; Simple support without Hadoop and Hive
		; If you need full support, install in Linux instead
		${SetEnvironmentVariablesPath} "SPARK_HOME" "$SparkDir"
		StrCpy "$ExtraPath" "$ExtraPath;$SparkDir\bin;$SparkDir\sbin"
		; Add Spark libraries to "PYTHONPATH", no need to install PySpark
		; However, when loading from zip, you can't debug the library source code
		${If} ${FileExists} "$SparkDir\python\lib\*.*"
			; Prioritize the non-zipped libraries first
			StrCpy "$PythonPath" "$PythonPath;$SparkDir\python"
			; Add the zipped libraries after that
			FindFirst $R1 $R2 "$SparkDir\python\lib\*.zip"
			CheckSparkLib:
			${If} $R2 != ""
				StrCpy "$PythonPath" "$PythonPath;$SparkDir\python\lib\$R2"
				FindNext $R1 $R2
				Goto CheckSparkLib
			${EndIf}
			FindClose $R1
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

	; Set or modify "PYTHONPATH"
	${SetEnvironmentVariablesPath} "PYTHONPATH" "$PythonPath"

	; Copy default "user-data" folder (first run)
	CreateDirectory "$VSCodeDataDir"
	${IfNot} ${FileExists} "$VSCodeDataDir\user-data\*.*"
		CopyFiles /Silent "$DefaultDataDir\VSCode\user-data\*.*" "$VSCodeDataDir\user-data"
	${EndIf}

	; Install bundled VSIX files to "extensions" folder (first run)
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

	; Rewrite values overwritten by VSCode at launch
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
	DeleteRegKey HKCU "Software\JavaSoft"
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

	; Android Studio/SDK related leftovers
	; Junction/symlink must be safely removed using cmd
	nsExec::Exec '"$CmdPath" /C "rmdir "$PROFILE\.android""'
	nsExec::Exec '"$CmdPath" /C "rmdir "$PROFILE\.gradle""'
	nsExec::Exec '"$CmdPath" /C "rmdir "$APPDATA\Google""'
	nsExec::Exec '"$CmdPath" /C "rmdir "$LOCALAPPDATA\Google""'
	nsExec::Exec '"$CmdPath" /C "rmdir "$LOCALAPPDATA\Android\Sdk""'
	DeleteRegKey HKCU "Software\JavaSoft\Android Open Source Project"
	RMDir "$LOCALAPPDATA\Android"
	RMDir /r "$LOCALAPPDATA\Android Open Source Project"
	RMDir /r "$LOCALAPPDATA\kotlin"
	Delete "$PROFILE\.emulator_console_auth_token"

	; Flutter (Dart) related leftovers
	RMDir /r "$APPDATA\.dart-tool"
	RMDir /r "$APPDATA\.dart"
	RMDir /r "$LOCALAPPDATA\.dartServer"
	RMDir /r "$LOCALAPPDATA\Pub\Cache"
	RMDir "$LOCALAPPDATA\Pub"
!macroend