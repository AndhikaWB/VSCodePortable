# Visual Studio Code Portable

Visual Studio Code in [PortableApps.com](https://portableapps.com/) format (unofficial).

Support some well known development environments, and will also try to portabilize files for those environments (e.g. Git, Python, Node.js). See the full list [here](App/FirstRun/settings/Custom.ini).

In order for portablization to work, you should always run from `VSCodePortable.exe` instead of `Code.exe` directly. `VSCodePortable.exe` will monitor things and clean them up when you close Visual Studio Code.

## Update Procedure

If you're using it for the first time, you can stop at step 2. If you're updating from older release, follow all these steps:

1. Download the latest [release](https://github.com/AndhikaWB/VSCodePortable/releases) of VSCodePortable
2. Run the portable installer, and it will download the latest version of VS Code automatically
3. If you want to update VS Code only (not the launcher), [download](https://go.microsoft.com/fwlink/?Linkid=850641) VS Code manually and replace the `App\VSCode` folder. However, don't delete the `App\VSCode\Data` folder because that's where your VS Code data are stored
4. Compare `Data\settings\Custom.ini` with `App\FirstRun\settings\Custom.ini` (the newest revision), and backup your `Data` folder. This is recommended because I occasionally release breaking changes (e.g. changing folder structures)
5. Run `VSCodePortable.exe`, test your usual environment (e.g. Python), and see if there's structural changes in the `Data` folder. Once you're familiar with the new changes, you can copy back your old data selectively
6. Done

**Note:** If Windows blocked you from running the app, right click the file, select "Properties" then "Unblock". This is the standard treatment for most files downloaded from the internet.

## Supported Environment

Below is an example of `Custom.ini` file (example may not be up-to-date). You can check what environments are supported in [this file](App/FirstRun/settings/Custom.ini).

```ini
[Path]
Base=%PATH%

[Git]
Path=%PAL:CommonFilesDir%\Git
; Change "HOME" to misc folder
ChangeUnixHome=true

[MinGW]
Path=%PAL:CommonFilesDir%\MinGW

[Java]
Path=%PAL:CommonFilesDir%\Java
; Change "GRADLE_USER_HOME" to misc folder
ChangeGradleUserHome=true

[Python]
Path=%PAL:CommonFilesDir%\Python
; Change "PYTHONUSERBASE" to misc folder
ChangePythonUserBase=true
; Change "PIP_CACHE_DIR" to misc folder
ChangePipCache=true
; Delete pip cache if the above is true
DeletePipCacheOnExit=true
; Change "JUPYTER_DATA_DIR" to misc folder
ChangeJupyterData=true

[R]
Path=%PAL:CommonFilesDir%\R
; Change "R_LIBS_USER" to misc folder
ChangeRLibsUser=true

[NodeJS]
Path=%PAL:CommonFilesDir%\NodeJS
; Change "NPM_CONFIG_PREFIX" to misc folder
ChangeNpmPrefix=true
; Delete npm cache if the above is true
DeleteNpmCacheOnExit=true

[Bun]
Path=%PAL:CommonFilesDir%\Bun
; Change "BUN_INSTALL" to misc folder
ChangeBunInstall=true
; Delete Bun cache if the above is true
DeleteBunCacheOnExit=true

[Go]
Path=%PAL:CommonFilesDir%\Go
; Change "GOPATH" to misc folder
ChangeGoPath=true

[Rust]
Path=%PAL:CommonFilesDir%\Rust
; Change "CARGO_HOME" to misc folder
ChangeCargoHome=true
; Delete Cargo cache if the above is true
DeleteCargeCacheOnExit=true

[Android]
StudioPath=%PAL:CommonFilesDir%\Android\Studio
; Change "idea.config.path" to misc folder
ChangeAndroidStudioConfig=true
; Force change SDK and AVD path with junction
; SDK and AVD path must exist for this to work
UseSdkAvdJunction=true
SdkPath=%PAL:CommonFilesDir%\Android\Sdk
AvdPath=%PAL:CommonFilesDir%\Android\Avd

[Flutter]
Path=%PAL:CommonFilesDir%\Flutter
; Change "PUB_CACHE" to misc folder
ChangePubCache=true

[PlatformIO]
; Change "PLATFORMIO_CORE_DIR" to misc folder
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
|[MSYS2](https://www.msys2.org/)|Lightweight WSL alternative that lets you download and update multiple packages using `pacman` without a hassle. Not thoroughly tested by me, some paths may differ than native Windows packages|

For other development environments that are not listed here (e.g. Node.js, Go, Rust), you can usually extract the files from installer using 7-Zip, Universal Extractor 2, or Sandboxie-Plus. However, try searching for `.zip` or `.tar` release first before relying on those programs!

## License

- VSCodePortable under the [GPL v2.0 license](https://github.com/AndhikaWB/VSCodePortable/blob/master/LICENSE)
- PortableApps.com Launcher under the [GPL v2.0 license](https://github.com/AndhikaWB/VSCodePortable/blob/master/LICENSE)
- Visual Studio Code under Microsoft custom [license](https://code.visualstudio.com/license)
