!macro RunModule module
	!ifdef _DisableHook_${module}_${__FUNCTION__}
		!echo "Module ${module}, hook ${__FUNCTION__} has been disabled by Custom.nsh."
	!else ifmacrondef ${module}.nsh_${__FUNCTION__}
		!if ${module} != Custom
			!warning "Module ${module}, hook ${__FUNCTION__} was called but does not exist!"
		!endif
	!else
		${!getdebug}
		!ifdef DEBUG && DEBUG_SEGWRAP
			${DebugMsg} "About to execute module"
		!endif
		!insertmacro ${module}.nsh_${__FUNCTION__}
		!ifdef DEBUG && DEBUG_SEGWRAP
			${DebugMsg} "Finished executing module"
		!endif
	!endif
!macroend

!macro ReadCustomConfig output section key default
	ClearErrors
	ReadINIStr ${output} $EXEDIR\Data\settings\Custom.ini ${section} ${key}
	${If} ${Errors}
		StrCpy ${output} ${default}
		WriteINIStr $EXEDIR\Data\settings\Custom.ini ${section} ${key} ${output}
	${EndIf}
!macroend

!macro RunCmd command
	nsExec::Exec '"$CmdPath" /C "${command}"'
!macroend

!macro RunCmdToLog command
	nsExec::ExecToLog '"$CmdPath" /C "${command}"'
!macroend

!macro RunCmdToStack command
	nsExec::ExecToStack '"$CmdPath" /C "${command}"'
!macroend

!macro CreateJunction link target
	${RunCmd} 'rmdir "${link}"'
	${RunCmd} 'mklink /J "${link}" "${target}"'
!macroend

!macro RemoveJunction link
	${RunCmd} 'rmdir "${link}"'
!macroend

!macro CreateShortcut link target
	Delete ${link}
	CreateShortcut ${link} ${target}
!macroend

!define RunModule "!insertmacro RunModule"
!define ReadCustomConfig "!insertmacro ReadCustomConfig"

!define RunCmd "!insertmacro RunCmd"
!define RunCmdToLog "!insertmacro RunCmdToLog"
!define RunCmdToStack "!insertmacro RunCmdToStack"

!define CreateJunction "!insertmacro CreateJunction"
!define RemoveJunction "!insertmacro RemoveJunction"
!define CreateShortcut "!insertmacro CreateShortcut"