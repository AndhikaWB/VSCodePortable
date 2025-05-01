Var RustDir
Var ChangeCargoHome

${SegmentFile}

${SegmentPreExec}
	${ReadUserConfig} "$RustDir" "RustDir"
	ExpandEnvStrings "$RustDir" "$RustDir"

	; If using Rustup, this should be somewhere in the "toolchains" folder
	; If you're using the standalone version, see the "rust-src" fix below
	; https://github.com/rust-lang/rust-analyzer/issues/4172#issuecomment-1664348160
	${If} ${FileExists} "$RustDir\bin\rustc.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$RustDir\bin"

		${ReadUserConfig} "$ChangeCargoHome" "ChangeCargoHome"
		${If} "$ChangeCargoHome" == "true"
			; Change Cargo home directory (the default is "%UserProfile%\.cargo")
			${SetEnvironmentVariablesPath} "CARGO_HOME" "$DataDir\misc\.cargo"
			; Just in case there are executable files in there
			StrCpy "$ExtraPath" "$ExtraPath;$DataDir\misc\.cargo\bin"
		${EndIf}
	${EndIf}
!macroend

${SegmentPostPrimary}
	; Cargo crate cache and unpacked source files
	${If} "$ChangeCargoHome" == "true"
		RMDir /r "$DataDir\misc\.cargo\registry\cache"
		RMDir /r "$DataDir\misc\.cargo\registry\src"
	${EndIf}

	; Stub Cargo directory
	RMDir "$PROFILE\.cargo"
!macroend