Var JavaDir
Var ChangeGradleUserHome

${SegmentFile}

${SegmentPreExec}
	${ReadUserConfig} "$JavaDir" "JavaDir"
	ExpandEnvStrings "$JavaDir" "$JavaDir"

	${If} ${FileExists} "$JavaDir\bin\java.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$JavaDir\bin"
		${SetEnvironmentVariablesPath} "JAVA_HOME" "$JavaDir"

		; Gradle is not really Java specific, but mostly used for Java
		${ReadUserConfig} "$ChangeGradleUserHome" "ChangeGradleUserHome"
		${If} "$ChangeGradleUserHome" == "true"
			; Change Gradle user home directory (the default is "%UserProfile%\.gradle")
			; https://docs.gradle.org/current/userguide/build_environment.html
			${SetEnvironmentVariablesPath} "GRADLE_USER_HOME" "$DataDir\misc\.gradle"
		${EndIf}
	${EndIf}
!macroend

${SegmentPostPrimary}
	; Java version and preferences
	DeleteRegKey HKCU "Software\JavaSoft"

	; Gradle tooling and cache files
	Delete "$PROFILE\.tooling\gradle\versions.json"
	RMDir "$PROFILE\.tooling\gradle"
	RMDir "$PROFILE\.tooling"
!macroend