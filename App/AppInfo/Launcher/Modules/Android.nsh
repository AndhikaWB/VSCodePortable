Var AndroidStudioDir
Var AndroidStudioExists

Var ChangeAndroidStudioConfig
Var AndroidStudioVersion

Var UseSdkAvdJunction
Var AndroidSdkDir
Var AndroidAvdDir

${SegmentFile}

${SegmentPreExec}
	${ReadCustomConfig} "$AndroidStudioDir" "Android" "StudioPath" "%PAL:CommonFilesDir%\Android\Studio"
	ExpandEnvStrings "$AndroidStudioDir" "$AndroidStudioDir"

	${If} ${FileExists} "$AndroidStudioDir\bin\studio64.exe"
		; Please run "studio64.exe" from VS Code terminal to launch it
		; If run directly from file explorer, it won't be portablized
		StrCpy "$ExtraPath" "$ExtraPath;$AndroidStudioDir\bin"

		; Can be read by "Flutter.nsh" and other launcher modules
		; However, "Android.nsh" (this file) must be loaded first
		StrCpy "$AndroidStudioExists" "true"

		; Get the X.Y version of Android Studio (e.g. 2024.3)
		${GetFileVersion} "$AndroidStudioDir\bin\studio64.exe" $R1
		${WordFind} $R1 "." "+2{" "$AndroidStudioVersion"

		; Flutter tries to find Android Studio by reading a dummy ".home" file
		; You can check this on the "android_studio.dart" file in the source code
		CreateDirectory "$LOCALAPPDATA\Google\AndroidStudio$AndroidStudioVersion"
		FileOpen $R1 "$LOCALAPPDATA\Google\AndroidStudio$AndroidStudioVersion\.home" "w"
		FileWrite $R1 "$AndroidStudioDir"
		FileClose $R1

		; Change Android Studio config and system files directory
		; Default config path: "%AppData%\Google\AndroidStudioX.Y"
		; Default system path: "%LocalAppData%\Google\AndroidStudioX.Y"
		${ReadCustomConfig} "$ChangeAndroidStudioConfig" "Android" "ChangeAndroidStudioConfig" "true"
		${If} "$ChangeAndroidStudioConfig" == "true"
			; Now unified in the ".AndroidStudio" directory
			StrCpy $R1 "$DataDir\misc\.AndroidStudio"
			CreateDirectory $R1

			; Copy the default properties and VM options file
			CopyFiles "$AndroidStudioDir\bin\idea.properties" $R1
			CopyFiles "$AndroidStudioDir\bin\studio64.exe.vmoptions" $R1

			; Overwrite the value on the properties file (path must use forward slash)
			ExpandEnvStrings $R2 "%PAL:DataDir:ForwardSlash%/misc/.AndroidStudio"
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

	; Android Studio doesn't always respect "ANDROID_HOME" and "ANDROID_AVD_HOME"
	; As a workaround, I simply use junctions to link those 2 directories
	${ReadCustomConfig} "$UseSdkAvdJunction" "Android" "UseSdkAvdJunction" "true"
	${If} "$UseSdkAvdJunction" == "true"
		; Create junction to Android SDK directory
		; The default is "%LocalAppData%\Android\Sdk"
		${ReadCustomConfig} "$AndroidSdkDir" "Android" "SdkPath" "%PAL:CommonFilesDir%\Android\Sdk"
		ExpandEnvStrings "$AndroidSdkDir" "$AndroidSdkDir"

		${If} ${FileExists} "$AndroidSdkDir\*.*"
			CreateDirectory "$LOCALAPPDATA\Android"
			${CreateJunction} "$LOCALAPPDATA\Android\sdk" "$AndroidSdkDir"
			; Add command line tools to "PATH" (for managing things without Android Studio)
			StrCpy "$ExtraPath" "$ExtraPath;$AndroidSdkDir\cmdline-tools\latest\bin"
		${EndIf}

		; Create junction to Android AVD directory
		; The default is "%UserProfile%\.android\avd"
		${ReadCustomConfig} "$AndroidAvdDir" "Android" "AvdPath" "%PAL:CommonFilesDir%\Android\Avd"
		ExpandEnvStrings "$AndroidAvdDir" "$AndroidAvdDir"

		${If} ${FileExists} "$AndroidAvdDir\*.*"
			CreateDirectory "$PROFILE\.android"
			${CreateJunction} "$PROFILE\.android\avd" "$AndroidAvdDir"
		${EndIf}

		; Android Studio may ignore this, but let's add it anyway
		${SetEnvironmentVariablesPath} "ANDROID_HOME" "$AndroidSdkDir"
		${SetEnvironmentVariablesPath} "ANDROID_AVD_HOME" "$AndroidAvdDir"
	${EndIf}
!macroend

${SegmentPostPrimary}
	; Android Studio dummy ".home" file
	${If} "$AndroidStudioExists" == "true"
		Delete "$LOCALAPPDATA\Google\AndroidStudio$AndroidStudioVersion\.home"
		RMDir "$LOCALAPPDATA\Google\AndroidStudio$AndroidStudioVersion"
	${EndIf}

	; Android SDK temporary files (e.g. incomplete downloads)
	; This won't delete temporary "system-images", must be checked manually
	RMDir /r "$LOCALAPPDATA\Android\sdk\.temp"

	; Android SDK and AVD junctions
	${If} "$UseSdkAvdJunction" == "true"
		${RemoveJunction} "$LOCALAPPDATA\Android\sdk"
		${RemoveJunction} "$PROFILE\.android\avd"
	${EndIf}

	; Android SDK manager cache (URL, license, and metadata)
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