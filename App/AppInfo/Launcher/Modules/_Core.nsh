!macro RunModule Module
	!ifdef _DisableHook_${Module}_${__FUNCTION__}
		!echo "Module ${Module}, hook ${__FUNCTION__} has been disabled by Custom.nsh."
	!else ifmacrondef ${Module}.nsh_${__FUNCTION__}
		!if ${Module} != Custom
			!warning "Module ${Module}, hook ${__FUNCTION__} was called but does not exist!"
		!endif
	!else
		${!getdebug}
		!ifdef DEBUG && DEBUG_SEGWRAP
			${DebugMsg} "About to execute module"
		!endif
		!insertmacro ${Module}.nsh_${__FUNCTION__}
		!ifdef DEBUG && DEBUG_SEGWRAP
			${DebugMsg} "Finished executing module"
		!endif
	!endif
!macroend

!define RunModule "!insertmacro RunModule"