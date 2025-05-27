Var RDir
Var ChangeRLibsUser

${SegmentFile}

${SegmentPreExec}
	${ReadCustomConfig} "$RDir" "R" "Path" "%PAL:CommonFilesDir%\R"
	ExpandEnvStrings "$RDir" "$RDir"

	${If} ${FileExists} "$RDir\bin\R.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$RDir\bin"
		${SetEnvironmentVariablesPath} "R_HOME" "$RDir"

		; Change the directory where R will install its packages
		; The default is "%LocalAppData%\R\win-library\X.Y" (version specific)
		; https://cran.r-project.org/bin/windows/base/rw-FAQ.html
		${ReadCustomConfig} "$ChangeRLibsUser" "R" "ChangeRLibsUser" "true"
		${If} "$ChangeRLibsUser" == "true"
			${RunCmdToStack} '"$RDir\bin\R.exe" -e "cat(paste(getRversion()))" --no-echo'
			Pop $R1

			${If} $R1 == 0
				Pop $R2
				; Take X.Y from X.Y.Z version number
				${WordFind} $R2 "." "+2{" $R3

				${SetEnvironmentVariablesPath} "R_LIBS_USER" "$DataDir\misc\AppData\Local\R\win-library\$R3"
				CreateDirectory "$DataDir\misc\AppData\Local\R\win-library\$R3"
			${EndIf}
		${EndIf}
	${EndIf}
!macroend