Var AndroidStudioDir
Var AndroidStudioExists

Var ChangeAndroidStudioConfig
Var AndroidStudioVer

Var CreateJunctionsToAndroid
Var PathToAndroidSdk
Var PathToAndroidAvd

${SegmentFile}

${SegmentPreExec}
	${ReadUserConfig} "$AndroidStudioDir" "AndroidStudioDir"
	ExpandEnvStrings "$AndroidStudioDir" "$AndroidStudioDir"

	${If} ${FileExists} "$AndroidStudioDir\bin\studio64.exe"
		; Please run "studio64.exe" from VS Code terminal to launch it
		; If run directly from file explorer, it won't be portablized
		StrCpy "$ExtraPath" "$ExtraPath;$AndroidStudioDir\bin"

		; Can be read by "Flutter.nsh" or other custom modules
		; However, "Android.nsh" (this file) must be loaded first
		StrCpy "$AndroidStudioExists" "true"

		; Get the X.Y version of Android Studio (e.g. 2024.3)
		${GetFileVersion} "$AndroidStudioDir\bin\studio64.exe" $R1
		${WordFind} $R1 "." "+2{" "$AndroidStudioVer"

		; Flutter tries to find Android Studio by reading a ".home" file
		; You can check this on the "android_studio.dart" file in the source code
		CreateDirectory "$LOCALAPPDATA\Google\AndroidStudio$AndroidStudioVer\system"
		FileOpen $R1 "$LOCALAPPDATA\Google\AndroidStudio$AndroidStudioVer\system\.home" "w"
		FileWrite $R1 "$AndroidStudioDir"
		FileClose $R1

		; Change Android Studio config and system files directory
		; Default config path: "%AppData%\Google\AndroidStudioX.Y"
		; Default system path: "%LocalAppData%\Google\AndroidStudioX.Y"
		${ReadUserConfig} "$ChangeAndroidStudioConfig" "ChangeAndroidStudioConfig"
		${If} "$ChangeAndroidStudioConfig" == "true"
			; Now unified in the ".AndroidStudio" directory
			StrCpy $R1 "$DataDir\misc\.AndroidStudio"
			CreateDirectory $R1

			; Copy the default properties and VM options file
			CopyFiles /Silent "$AndroidStudioDir\bin\idea.properties" $R1
			CopyFiles /Silent "$AndroidStudioDir\bin\studio64.exe.vmoptions" $R1

			; Overwrite the value on the properties file (path must use forward slash)
			ExpandEnvStrings $R2 "%PAL:DataDir:ForwardSlash%/.AndroidStudio"
			${ConfigWrite} "$R1\idea.properties" "idea.config.path=" "$R2/config" $R3
			${ConfigWrite} "$R1\idea.properties" "idea.system.path=" "$R2/system" $R3
			${ConfigWrite} "$R1\idea.properties" "idea.plugins.path=" "$R2/config/plugins" $R3
			${ConfigWrite} "$R1\idea.properties" "idea.log.path=" "$R2/system/log" $R3

			; Set the location of both files through environment variable
			; https://developer.android.com/tools/variables
			${SetEnvironmentVariablesPath} "STUDIO_PROPERTIES" "$R1\idea.properties"
			${SetEnvironmentVariablesPath} "STUDIO_VM_OPTIONS" "$R1\studio64.exe.vmoptions"
		${EndIf}
	${EndIf}

	; Android Studio doesn't always respect "ANDROID_HOME" and "ANDROID_USER_HOME"
	; As a workaround, I simply use junctions to link those 2 directories
	; The junction will not be created if the linked directory already exists
	${ReadUserConfig} "$CreateJunctionsToAndroid" "CreateJunctionsToAndroid"
	${If} "$CreateJunctionsToAndroid" == "true"
		; Create junction to Android SDK directory
		; The default is "%LocalAppData%\Android\Sdk"
		${ReadUserConfig} "$PathToAndroidSdk" "PathToAndroidSdk"
		ExpandEnvStrings "$PathToAndroidSdk" "$PathToAndroidSdk"

		${If} ${FileExists} "$PathToAndroidSdk\*.*"
			CreateDirectory "$LOCALAPPDATA\Android"
			; Try to delete empty directory before linking the junction
			nsExec::Exec '"$CmdPath" /C "rmdir "$LOCALAPPDATA\Android\Sdk""'
			nsExec::Exec '"$CmdPath" /C "mklink /J "$LOCALAPPDATA\Android\Sdk" "$PathToAndroidSdk""'
			; Add command line tools to "PATH" (for managing things without Android Studio)
			StrCpy "$ExtraPath" "$ExtraPath;$PathToAndroidSdk\cmdline-tools\latest\bin"
		${EndIf}

		; Create junction to Android AVD directory
		; The default is "%UserProfile%\.android\avd"
		${ReadUserConfig} "$PathToAndroidAvd" "PathToAndroidAvd"
		ExpandEnvStrings "$PathToAndroidAvd" "$PathToAndroidAvd"

		${If} ${FileExists} "$PathToAndroidAvd\*.*"
			CreateDirectory "$PROFILE\.android"
			; Try to delete empty directory before linking the junction
			nsExec::Exec '"$CmdPath" /C "rmdir "$PROFILE\.android\avd""'
			nsExec::Exec '"$CmdPath" /C "mklink /J "$PROFILE\.android\avd" "$PathToAndroidAvd""'
		${EndIf}

		${SetEnvironmentVariablesPath} "ANDROID_HOME" "$LOCALAPPDATA\Android\Sdk"
		${SetEnvironmentVariablesPath} "ANDROID_AVD_HOME" "$PROFILE\.android\avd"
		${SetEnvironmentVariablesPath} "ANDROID_USER_HOME" "$DataDir\misc\.android"
	${EndIf}
!macroend

${SegmentPostPrimary}
	; Android Studio dummy ".home" file
	${If} "$AndroidStudioExists" == "true"
		Delete "$LOCALAPPDATA\Google\AndroidStudio$AndroidStudioVer\system\.home"
		RMDir "$LOCALAPPDATA\Google\AndroidStudio$AndroidStudioVer\system"
		RMDir "$LOCALAPPDATA\Google\AndroidStudio$AndroidStudioVer"
	${EndIf}

	; Android SDK and AVD junctions
	${If} "$CreateJunctionsToAndroid" == "true"
		nsExec::Exec '"$CmdPath" /C "rmdir "$LOCALAPPDATA\Android\Sdk""'
		nsExec::Exec '"$CmdPath" /C "rmdir "$PROFILE\.android\avd""'
	${EndIf}

	; Android SDK manager cache (license, metadata, etc.)
	Delete "$PROFILE\.android\cache\*.xml"
	RMDir "$PROFILE\.android\cache"

	; Emulator console auth token (will be recreated if deleted)
	Delete "$PROFILE\.emulator_console_auth_token"

	; Android Studio consent options file
	Delete "$APPDATA\Google\consentOptions\accepted"
	RMDir "$APPDATA\Google\consentOptions"

	; Android stub directories
	RMDir "$PROFILE\.android"
	RMDir "$LOCALAPPDATA\Android"
	RMDir "$LOCALAPPDATA\Google"
	RMDir "$APPDATA\Google"

	; Android emulator settings
	DeleteRegKey /ifempty HKCU "Software\Android Open Source Project\Emulator\set"
	DeleteRegKey /ifempty HKCU "Software\Android Open Source Project\Emulator"
	DeleteRegKey /ifempty HKCU "Software\Android Open Source Project"
!macroend