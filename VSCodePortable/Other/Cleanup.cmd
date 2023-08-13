@echo off
pushd "%~dp0"
echo/
echo WARNING: This will delete all your VSCode data!
echo Please make sure you know what you are doing.
pause
echo/
:: VSCode
rmdir /s /q "%AppData%\Code"
rmdir /s /q "%AppData%\Visual Studio Code"
rmdir /s /q "%UserProfile%\.vscode"
:: C++
rmdir /s /q "%LocalAppData%\Microsoft\vscode-cpptools"
:: Python
rmdir /s /q "%UserProfile%\.pylint.d"
rmdir /s /q "%LocalAppData%\Jedi"
rmdir /q "%LocalAppData%\pip\cache"
rmdir /q "%LocalAppData%\pip"
:: Java
del /q "%UserProfile%\.tooling\gradle\versions.json"
rmdir /q "%UserProfile%\.tooling\gradle"
rmdir /q "%UserProfile%\.tooling"
:: Node.js
del /q "%UserProfile%\.config\configstore\update-notifier-npm.json"
rmdir /q "%UserProfile%\.config\configstore"
rmdir /q "%UserProfile%\.config"
rmdir /q "%AppData%\npm-cache"
rmdir /q "%AppData%\npm"
:: Golang
rmdir /q "%LocalAppData%\go-build"
rmdir /q "%LocalAppData%\gopls"
rmdir /q "%LocalAppData%\staticcheck"
:: Rust
rmdir /q "%UserProfile%\.cargo\registry"
rmdir /q "%UserProfile%\.cargo"
echo/
:: VSCode registry
reg delete "HKCR\vscode" /f
reg delete "HKCU\Software\Classes\vscode" /f
reg delete "HKCU\Software\Classes\*\shell\VSCode" /f
reg delete "HKCU\Software\Classes\directory\shell\VSCode" /f
reg delete "HKCU\Software\Classes\directory\background\shell\VSCode" /f
reg delete "HKCU\Software\Classes\Drive\shell\VSCode" /f
:: Live Share registry
reg delete "HKCR\vsls" /f
reg delete "HKCR\code.launcher.handler" /f
reg delete "HKCU\Software\Classes\vsls" /f
reg delete "HKCU\Software\Classes\code.launcher.handler" /f
reg delete "HKCU\Software\code.launcher" /f
reg delete "HKCU\Software\RegisteredApplications" /v "code.launcher" /f
echo/
pause
