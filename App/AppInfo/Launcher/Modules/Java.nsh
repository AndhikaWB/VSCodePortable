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

	${If} "$ChangeGradleUserHome" == "true"
		; Gradle daemon log files
		FindFirst $R1 $R2 "$DataDir\misc\.gradle\daemon\*.*"
		CheckLog:
		${If} $R2 != ""
			Delete "$DataDir\misc\.gradle\daemon\$R2\*.log"
			FindNext $R1 $R2
			Goto CheckLog
		${EndIf}
		FindClose $R1

		; Gradle temporary files
		RMDir /r "$DataDir\misc\.gradle\.tmp"
	${EndIf}
!macroend