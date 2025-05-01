# Visual Studio Code Portable

Visual Studio Code in [PortableApps.com](https://portableapps.com/) format (unofficial).

Support some well known development environments, and will also try to portabilize files for those environments (e.g. Git, Python, Node.js). See the full list [here](App\FirstRun\VSCodePortable.ini).

In order for portablization to work, you should always run from `VSCodePortable.exe` instead of `Code.exe` directly. `VSCodePortable.exe` will monitor things and clean them up when you close Visual Studio Code.

## Update Procedure

If you're using it for the first time, you can stop at step 2. If you're updating from older release, follow all these steps.

1. Download the latest [release](https://github.com/AndhikaWB/VSCodePortable/releases) of VSCodePortable
2. Run the portable installer, and it will download the latest version of VS Code automatically
3. If you want to update VS Code only (not the launcher), [download](https://go.microsoft.com/fwlink/?Linkid=850641) VS Code manually and replace the `App\VSCode` folder. However, don't delete the `App\VSCode\Data` folder because that's where your VS Code data are stored
4. Replace `{ROOT}\VSCodePortable.ini` with `App\FirstRun\VSCodePortable.ini` (the newest version), and backup your `{ROOT}\Data` folder. This is recommended because I occasionally release breaking changes (e.g. changed folder structure in `{ROOT}\Data`)
5. Run `VSCodePortable.exe`, test your usual environment (e.g. Python), and see if there's structural changes in the `{ROOT}\Data` folder. Once you're familiar with the new changes, you can copy back your old data
6. Done

**Note:** If Windows blocked you from running the app, right click the file, select "Properties" then "Unblock". This is the standard treatment for most files downloaded from the internet.

## Supported Environment

Below is an example of `{ROOT}\VSCodePortable.ini` file (example may not be up to date). You can check what environments are supported on this file

```ini
[Launch]
; Additional parameters to pass to VS Code
AdditionalParameters=
; Override "PATH" variable for the VS Code process
; Use "%PATH%;XXX" to append directory to original "PATH"
; Use "%__clean__%" to emulate clean Windows 11 "PATH"
OverridePath=

[Git]
; Will check "$GitDir\cmd\git.exe"
GitDir=%PAL:CommonFilesDir%\Git
; Change to "Data\misc"
ChangeUnixHome=true

[MinGW]
; Will check "$MinGWDir\bin\gcc.exe"
MinGWDir=%PAL:CommonFilesDir%\MinGW

[Java]
; Will check "$JavaDir\bin\java.exe"
JavaDir=%PAL:CommonFilesDir%\OpenJDK
; Change to "Data\misc\.gradle"
ChangeGradleUserHome=true

[Python]
; Will check "$PythonDir\python.exe"
PythonDir=%PAL:CommonFilesDir%\Python
; Change to "Data\misc\AppData\Roaming\Python"
ChangePythonUserBase=true
; Change to "Data\misc\AppData\Local\pip\cache"
ChangePipCache=true
; Change to "Data\misc\AppData\Roaming\jupyter"
ChangeJupyterData=true

[R]
; Will check "$RDir\bin\R.exe"
RDir=%PAL:CommonFilesDir%\R
; Change to "Data\misc\AppData\Local\R\win-library\X.Y"
ChangeRLibsUser=true

[NodeJS]
; Will check "$NodeJSDir\node.exe"
NodeJSDir=%PAL:CommonFilesDir%\Node.js
; Change to "Data\misc\AppData\Roaming\npm"
ChangeNPMPrefix=true

[Bun]
; Will check "$BunDir\bin\bun.exe"
BunDir=%PAL:CommonFilesDir%\Bun
; Change to "Data\misc\.bun"
ChangeBunInstall=true

[Go]
; Will check "$GoDir\bin\go.exe"
GoDir=%PAL:CommonFilesDir%\Go
; Change to "Data\misc\Go"
ChangeGoPath=true

[Rust]
; Will check "$RustDir\bin\rustc.exe"
RustDir=%PAL:CommonFilesDir%\Rust
; Change to "Data\misc\Rust\.cargo"
ChangeCargoHome=true

[Android]
; Will check "$AndroidStudioDir\bin\studio64.exe"
AndroidStudioDir=%PAL:CommonFilesDir%\Android\Studio
; Change to "Data\misc\.AndroidStudio"
ChangeAndroidStudioConfig=true
; Create junctions to directories below (the path must exist)
CreateJunctionsToAndroid=true
; "$PathToAndroidSdk" will link to "%LocalAppData%\Android\Sdk"
PathToAndroidSdk=%PAL:CommonFilesDir%\Android\Sdk
; "$PathToAndroidAvd" will link to "%UserProfile%\.android\avd"
PathToAndroidAvd=%PAL:CommonFilesDir%\Android\Avd

[Flutter]
; Will check "$FlutterDir\bin\dart.bat"
FlutterDir=%PAL:CommonFilesDir%\Flutter
; Change to "Data\misc\AppData\Local\Pub\Cache"
ChangePubCache=true

[PlatformIO]
; Change to "Data\misc\.platformio"
ChangePlatformIOCore=true
```

The logic behind these lies in the `App\AppInfo\Launcher` folder. If you made changes to files in this folder, recompile the launcher using [this app](https://portableapps.com/apps/development/portableapps.com_launcher).

## Path Alias

If you place `VSCodePortable` on `C:\Apps\VSCodePortable`, then:

- `%PAL:CommonFilesDir%` will be `C:\Apps\CommonFiles`
- `%PAL:AppDir%` will be `C:\Apps\VSCodePortable\App`
- `%PAL:DataDir%` will be `C:\Apps\VSCodePortable\Data`
- `%PAL:LauncherDir%` will be `C:\Apps\VSCodePortable`
- `%PAL:PortableAppsDir%` will be `C:\Apps`

See more path alias from [here](https://portableapps.com/manuals/PortableApps.comLauncher/ref/launcher.ini/environment.html).

## Where to Get Portable XXX?

Here are some sources I personally use:

|Source|Description|
|-|-|
|[WinLibs](https://winlibs.com/)|Provides up-to-date GCC for Windows, faster than [Mingw-w64](https://www.mingw-w64.org/) (which is usually slow at releasing updates)|
|[Nuwen.net](https://nuwen.net/mingw.html)|May not always provides the latest version of GCC, but you can select only the components you need (smaller overall size)|
|[Adoptium](https://adoptium.net/temurin/releases/)|Provides open-source version of (Java) JDK and JRE. Formerly known as [AdoptOpenJDK](https://adoptopenjdk.net/releases.html)|
|[WinPython](https://winpython.github.io/)|Provides portable installer for Python. This is great since the official Python installer usually can't be extracted properly using workarounds (see below table).|
|[MinGit](https://github.com/git-for-windows/git/releases)|Absolute minimal Git directly from the official repo (see [wiki](https://github.com/git-for-windows/git/wiki/MinGit)), even smaller than the portable installer|
|[MSYS2](https://www.msys2.org/)|Lightweight WSL alternative that lets you download and update multiple packages using `pacman` without a hassle. Not thoroughly tested by me, some paths may differ than native packages|

For other development environments that are not listed here (e.g. Node.js, Go, Rust), you can usually extract the files from installer using 7-Zip, Universal Extractor 2, or Sandboxie-Plus. However, try searching for `.zip` or `.tar` release first before relying on those programs!

## License

- VSCodePortable under the [GPL v2.0 license](https://github.com/AndhikaWB/VSCodePortable/blob/master/LICENSE)
- PortableApps.com Launcher under the [GPL v2.0 license](https://github.com/AndhikaWB/VSCodePortable/blob/master/LICENSE)
- Visual Studio Code under Microsoft custom [license](https://code.visualstudio.com/license)
