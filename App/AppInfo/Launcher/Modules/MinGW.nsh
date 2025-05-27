Var MinGWDir

${SegmentFile}

${SegmentPreExec}
	${ReadCustomConfig} "$MinGWDir" "MinGW" "Path" "%PAL:CommonFilesDir%\MinGW"
	ExpandEnvStrings "$MinGWDir" "$MinGWDir"

	${If} ${FileExists} "$MinGWDir\bin\gcc.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$MinGWDir\bin"
	${EndIf}
!macroend

${SegmentPostPrimary}
	; VS Code C++ extension cache files
	RMDir /r "$LOCALAPPDATA\Microsoft\vscode-cpptools"
!macroend