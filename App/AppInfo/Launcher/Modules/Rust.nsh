Var RustDir
Var ChangeCargoHome
Var DeleteCargeCacheOnExit

${SegmentFile}

${SegmentPreExec}
	${ReadCustomConfig} "$RustDir" "Rust" "Path" "%PAL:CommonFilesDir%\Rust"
	ExpandEnvStrings "$RustDir" "$RustDir"

	; If using Rustup, this should be somewhere in the "toolchains" folder
	; If you're using the standalone version, download "rust-src" below if needed
	; https://github.com/rust-lang/rust-analyzer/issues/4172#issuecomment-1664348160
	${If} ${FileExists} "$RustDir\bin\rustc.exe"
		StrCpy "$ExtraPath" "$ExtraPath;$RustDir\bin"

		${ReadCustomConfig} "$ChangeCargoHome" "Rust" "ChangeCargoHome" "true"
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
		${ReadCustomConfig} "$DeleteCargeCacheOnExit" "Rust" "DeleteCargeCacheOnExit" "true"
		${If} "$DeleteCargeCacheOnExit" == "true"
			RMDir /r "$DataDir\misc\.cargo\registry\cache"
			RMDir /r "$DataDir\misc\.cargo\registry\src"
		${EndIf}
	${EndIf}

	; Cargo stub directory
	RMDir "$PROFILE\.cargo"
!macroend