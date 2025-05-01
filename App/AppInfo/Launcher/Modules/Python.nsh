Var PythonDir
Var ChangePythonUserBase
Var ChangePipCache
Var ChangeJupyterData

${SegmentFile}

${SegmentPreExec}
	${ReadUserConfig} "$PythonDir" "PythonDir"
	ExpandEnvStrings "$PythonDir" "$PythonDir"

	${If} ${FileExists} "$PythonDir\python.exe"
		${ReadUserConfig} "$ChangePythonUserBase" "ChangePythonUserBase"
		${If} "$ChangePythonUserBase" == "true"
			; Change Python user base directory (the default is "%AppData%\Python")
			; This will affect user libraries only, not globally installed libraries
			; https://docs.python.org/3/using/cmdline.html#environment-variables
			${SetEnvironmentVariablesPath} "PYTHONUSERBASE" "$DataDir\misc\AppData\Roaming\Python"
		${EndIf}

		${ReadUserConfig} "$ChangePipCache" "ChangePipCache"
		${If} "$ChangePipCache" == "true"
			; Change Pip cache directory (the default is "%LocalAppData%\pip\cache")
			${SetEnvironmentVariablesPath} "PIP_CACHE_DIR" "$DataDir\misc\AppData\Local\pip\cache"
		${EndIf}

		; Jupyter is not really Python specific, but mostly used for Python
		${ReadUserConfig} "$ChangeJupyterData" "ChangeJupyterData"
		${If} "$ChangeJupyterData" == "true"
			; Change Jupyter kernel and extension data directory (the default is "%AppData%\jupyter")
			; "JUPYTER_PATH" is needed because Jupyter can't find the new directory automatically
			; https://docs.jupyter.org/en/latest/use/jupyter-directories.html
			${SetEnvironmentVariablesPath} "JUPYTER_DATA_DIR" "$DataDir\misc\AppData\Roaming\jupyter"
			${SetEnvironmentVariablesPath} "JUPYTER_PATH" "$DataDir\misc\AppData\Roaming\jupyter"
		${EndIf}

		; Get user "scripts" directory and add it to "PATH"
		; The default is "%AppData%\Python\PythonXXX\site-packages" (version specific)
		nsExec::ExecToStack '"$PythonDir\python.exe" -m site --user-site'
		Pop $R1

		${If} $R1 == 0
			Pop $R2
			${GetParent} $R2 $R2
			StrCpy "$ExtraPath" "$ExtraPath;$PythonDir;$PythonDir\scripts;$R2\scripts"
		${Else}
			StrCpy "$ExtraPath" "$ExtraPath;$PythonDir;$PythonDir\scripts"
		${EndIf}
	${EndIf}
!macroend

${SegmentPostPrimary}
	; Jupyter config files (see above link)
	Delete "$PROFILE\.jupyter\migrated"
	RMDir "$PROFILE\.jupyter"

	; Keras base directory (downloaded models, etc.)
	; https://keras.io/api/applications/
	Delete "$PROFILE\.keras\keras.json"
	RMDir "$PROFILE\.keras"

	; IPython config files, command history, etc.
	; https://ipython.readthedocs.io/en/stable/config/intro.html
	RMDir /r "$PROFILE\.ipython"

	; Matplotlib customization, font cache, etc.
	; https://matplotlib.org/stable/install/environment_variables_faq.html
	RMDir /r "$PROFILE\.matplotlib"

	; Pip cache files
	${If} "$ChangePipCache" == "true"
		RMDir /r "$DataDir\misc\AppData\Local\pip\cache"
	${EndIf}

	; Pip stub directories
	RMDir "$LOCALAPPDATA\pip\cache"
	RMDir "$LOCALAPPDATA\pip"
!macroend