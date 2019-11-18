${SegmentFile}

; Large strings build of NSIS is recommended
; https://nsis.sourceforge.io/Special_Builds

${SegmentPre}
	${If} ${FileExists} '$PROFILE\AppData\LocalLow\*.*'
		${SetEnvironmentVariablesPath} LOCALAPPDATALOW '$PROFILE\AppData\LocalLow'
	${EndIf}

	${SetEnvironmentVariablesPath} PAL:LAUNCHERPATH $EXEPATH
	${SetEnvironmentVariablesPath} PAL:LAUNCHERDIR $EXEDIR
	${SetEnvironmentVariablesPath} PAL:LAUNCHERFILE $EXEFILE

	${SetEnvironmentVariablesPath} PAL:PORTABLEAPPSDIR $PortableAppsDirectory
	${SetEnvironmentVariablesPath} PAL:COMMONFILESDIR '$PortableAppsDirectory\CommonFiles'

	ReadEnvStr $0 PATH

	; This folder will be injected into the PATH environment variable
	; Place your tools here so you can easily execute them later
	; Subfolders are ignored, except for the "bin" subfolder

	${ReadLauncherConfig} $1 Environment CUSTOM_ROOT
	ExpandEnvStrings $1 $1
	${If} ${FileExists} '$1\*.*'
		${If} ${FileExists} '$1\bin\*.*'
			StrCpy $0 '$0;$1;$1\bin'
		${Else}
			StrCpy $0 '$0;$1'
		${EndIf}
	${EndIf}

	; Some MSYS2 packages are currently unsupported
	; They may have different folder structures

	${ReadLauncherConfig} $2 Environment GIT_ROOT
	ExpandEnvStrings $2 $2
	${If} ${FileExists} '$2\cmd\git.exe'
		StrCpy $0 '$0;$2\cmd'
	${EndIf}

	${ReadLauncherConfig} $3 Environment MINGW_ROOT
	ExpandEnvStrings $3 $3
	${If} ${FileExists} '$3\bin\gcc.exe'
		StrCpy $0 '$0;$3\bin'
	${EndIf}

	${ReadLauncherConfig} $4 Environment PYTHON_ROOT
	ExpandEnvStrings $4 $4
	${If} ${FileExists} '$4\python.exe'
		${If} ${FileExists} '$4\scripts\*.*'
			StrCpy $0 '$0;$4;$4\scripts'
		${Else}
			StrCpy $0 '$0;$4'
		${EndIf}
	${EndIf}
	${If} ${FileExists} '$4\lib\*.*'
		${If} ${FileExists} '$4\dlls\*.*'
			${SetEnvironmentVariablesPath} PYTHONPATH '$4\lib;$4\dlls'
		${Else}
			${SetEnvironmentVariablesPath} PYTHONPATH '$4\lib'
		${EndIf}
	${EndIf}

	${ReadLauncherConfig} $5 Environment JAVA_ROOT
	ExpandEnvStrings $5 $5
	${If} ${FileExists} '$5\bin\java.exe'
		StrCpy $0 '$0;$5\bin'
		${SetEnvironmentVariablesPath} JAVA_HOME $5
	${EndIf}

	StrLen $R0 $0
	IntOp $R0 $R0 + 1 ; All characters plus a terminator
	${If} ${NSIS_CHAR_SIZE} > 1 ; If using UNICODE instead of ANSI
		IntOp $R0 $R0 * ${NSIS_CHAR_SIZE}
	${EndIf}
	${If} $R0 < ${NSIS_MAX_STRLEN}
		${SetEnvironmentVariablesPath} PATH $0
	${Else}
		MessageBox MB_OK|MB_ICONSTOP 'The PATH environment variable is too long. Try shortening it or use a special build of NSIS.'
		Abort
	${EndIf}
!macroend

${SegmentPrePrimary}
	; Prevent "Windows can't find ..." error
	CreateDirectory '$DataDirectory\Virtual\Desktop'
	CreateDirectory '$DataDirectory\Virtual\AppData\Roaming'
	CreateDirectory '$DataDirectory\Virtual\AppData\Local'
	CreateDirectory '$DataDirectory\Virtual\ProgramData'
!macroend