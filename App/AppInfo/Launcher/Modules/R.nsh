Var RDir
Var ChangeRLibsUser

${SegmentFile}

${SegmentPreExec}
	${ReadUserConfig} "$RDir" "RDir"
	ExpandEnvStrings "$RDir" "$RDir"

	${If} ${FileExists} "$RDir\bin\R.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$RDir\bin"
		${SetEnvironmentVariablesPath} "R_HOME" "$RDir"

		${ReadUserConfig} "$ChangeRLibsUser" "ChangeRLibsUser"
		${If} "$ChangeRLibsUser" == "true"
			; R will install packages to "R_HOME/library" if the path is writable
			; This behavior can be overridden by setting "R_LIBS_USER" variable
			; The default is "%LocalAppData%\R\win-library\X.Y" (version specific)
			; https://cran.r-project.org/bin/windows/base/rw-FAQ.html

			nsExec::ExecToStack `"$RDir\bin\R.exe" -e "cat(sessionInfo()$R.version$major,'.',sessionInfo()$R.version$minor,sep='')" --no-echo`
			Pop $R1

			${If} $R1 == 0
				; Take only the X.Y from X.Y.Z version number
				Pop $R2
				${WordFind} $R2 "." "-1{" $R3

				${SetEnvironmentVariablesPath} "R_LIBS_USER" "$DataDir\misc\AppData\Local\R\win-library\$R3"
				CreateDirectory "$DataDir\misc\AppData\Local\R\win-library\$R3"
			${EndIf}
		${EndIf}
	${EndIf}
!macroend