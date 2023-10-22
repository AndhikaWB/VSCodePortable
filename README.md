# VSCodePortable

Visual Studio Code in [PortableApps.com](https://portableapps.com/) format (unofficial). Can possibly be applied to VSCodium too.

# FAQ

### Why do I need it if Visual Studio Code already support native [portable](https://code.visualstudio.com/docs/editor/portable) mode?

Native portable mode can still leave some traces on the system and registry (created by extensions and development environments). Moreover, you still need to add your (portable) development environments to `PATH` manually and sometimes, this process is tiring, especially if you want to set them up on multiple computers or need to change the `PATH` oftenly.

With VSCodePortable, you can just pack your development environments together (along with VSCodePortable), copy them to flash drive, and run them again on different computer without needing to set up them again (see below for more details).

### What are the differences compared to native portable mode?

* All known traces (on the system and registry) will be removed automatically after run. Including some traces left by extensions and development environments. Check `VSCodePortable.ini` and `Custom.nsh` file in `App\AppInfo\Launcher` folder for more details.
* Support some popular development environments (see below), they will be added to `PATH` automatically during runtime. Only affects `Code.exe` and processes run by it, your real `PATH` environment variable will stay untouched. You can specify their location by modifying `VSCodePortable.ini` file in root directory (appears only after the first run).
* Added context menu items (e.g. `Open with Code`) just like the non-portable version. Will be removed automatically after you close Visual Studio Code (please don't shut down your system directly, close VSCodePortable first).
* Can auto-install VSIX files located in `App\FirstRun\VSCode\extensions` folder on first run. Be aware that some extensions require other extension as dependency, you can add number in front of the file name because they will be installed in descending order.
* Disabled telemetry and auto-update (via `settings.json`)

### What are the differences between this and Gareth Flower's [vscode-portable](https://github.com/garethflowers/vscode-portable)?

As far as I know, Flower's version has similar behavior compared to native portable mode. My version has some extra features that I needed personally (as stated above).

### Why not use VSCodium as the base instead?

VSCodium is not allowed to use any [proprietary debugging tools](https://github.com/VSCodium/vscodium/blob/master/DOCS.md#proprietary-debugging-tools) made by Microsoft, including those that are embedded on extensions like [C/C++ extension](https://github.com/Microsoft/vscode-cpptools/issues/21#issuecomment-248349017), and many more. It seems that there is [workaround](https://aur.archlinux.org/packages/vscodium-bin-marketplace), but I don't have a clean way to modify and support it right now (feel free to open PR). Moreover, some extensions still doesn't work properly even after using that patch.

### Which development environments are supported?
It supports Git, MinGW (GCC), Python, Java, Node.js, Go, Rust, Flutter, Android Studio, Android SDK, Apache Spark, and PlatformIO. Visual Studio build tools support is also (partially) supported, see my other repo ([BuildToolsInspector](https://github.com/AndhikaWB/BuildToolsInspector)). You can enable optional modification(s) for each DE via `VSCodePortable.ini` (on the launcher root directory).

When updating VSCodePortable from the [release](https://github.com/AndhikaWB/VSCodePortable/releases) page, please compare the previously mentioned file with `App\FirstRun\VSCodePortable.ini` in case I added support for new feature(s), since the existing config file will not be replaced automatically. Sorry for the inconvenience.

### Will XXX development environment be supported?
Open an issue or pull request and I will see what I can do.
  
# Other Notes

### How to use?

1. Download the latest [release](https://github.com/AndhikaWB/VSCodePortable/releases) of VSCodePortable
2. Extract it anywhere (e.g. `D:\Apps\VSCodePortable`), but avoid using very long path
3. Download Visual Studio Code (`.zip` format) from [here](https://code.visualstudio.com/#alt-downloads)
4. Extract it to `D:\Apps\VSCodePortable\App\VSCode`
5. Done, always start Visual Studio Code by using `VSCodePortable.exe`

**Note:** If you're using the portable installer from [release](https://github.com/AndhikaWB/VSCodePortable/releases) page (`.exe`, not `.zip`), step 2-5 are unnecessary since the latest version of VSCode will be downloaded automatically.

### Setting-up development environment

Required to be able to recognize your (portable) development environments.

1. Open `VSCodePortable.exe` at least once
2. Navigate to `D:\Apps\VSCodePortable` (or wherever your install directory is)
3. Open `VSCodePortable.ini` by using any text editor
4. Look out for `[Environment]` section and change the values (`GIT`, `MINGW`, `PYTHON`, etc) to real path where your development environment exist (please don't point to `bin` folder directly, just the root folder). If the folder/path doesn't exist, it will simply be ignored
5. Done, if you change it to the right path, Visual Studio Code will now be able to recognize your (portable) development environment
6. If you are still unsure, check it by running the development environment executable (e.g. `gcc --version`, `python --version`) inside Visual Studio Code terminal

### Adding unsupported development environment

1. Open `VSCodePortable.exe` at least once
2. Navigate to `D:\Apps\VSCodePortable` (or wherever your install directory is)
3. Open `VSCodePortable.ini` by using any text editor
4. Look out for the `[Environment]` section and change `PATH` value
5. To append original system `PATH`, use something like `PATH=%PATH%;<path_to_your_de>`. You can also use `PATH=__clean__` to emulate `PATH` on clean Windows install
6. (Optional) if the development environment checks for specific environment variable (e.g. `XXX_HOME`, `XXXPATH`), navigate to `D:\Apps\VSCodePortable\App\AppInfo\Launcher` and open `VSCodePortable.ini` file. Add new `[Environment]` section (if it doesn't exist) and write the needed environment variable (e.g. `XXX_HOME=D:\Apps\CommonFiles\XXX`) under that section
7. To check if your environment variable is recognized, type `echo %PATH%` (Command Prompt) or `echo $PATH` (Bash) or `$env:PATH` (PowerShell) inside Visual Studio Code terminal. Replace `PATH` with other variable name depending on your use case

**Note:** There are at least 3 different `VSCodePortable.ini` files! Usually you only need to look the one located in launcher root directory. However, check the instruction again and make sure you modify the correct one!

### Supported environment variables

Assuming that you installed VSCodePortable on `D:\Apps\VSCodePortable` (where `VSCodePortable.exe` exist), here is some useful environment variable paths you can use:

* Mainly read by `VSCodePortable.exe` (the launcher):
  * `PAL:DataDir` : `D:\Apps\VSCodePortable\Data`
  * `PAL:AppDir` : `D:\Apps\VSCodePortable\App`
  * `PAL:LauncherDir` : `D:\Apps\VSCodePortable`
  * `PAL:LauncherPath` : `D:\Apps\VSCodePortable\VSCodePortable.exe`
  * `PAL:LauncherFile` : `VSCodePortable.exe`
  * `PAL:PortableAppsDir` : `D:\Apps`
  * `PAL:CommonFilesDir` : `D:\Apps\CommonFiles`
  * More from [here](https://portableapps.com/manuals/PortableApps.comLauncher/ref/launcher.ini/environment.html)

* Frequently read by `Code.exe` and other processes:
  * `UserProfile` : `C:\User\<your_username>`
  * `AppData` : `C:\User\<your_username>\AppData\Roaming`
  * `LocalAppData` : `C:\User\<your_username>\AppData\Local`
  * `ProgramData`/`AllUsersProfile` : `C:\ProgramData`
  * `SystemRoot` : `C:\Windows`
  * More from [here](https://ss64.com/nt/syntax-variables.html)

**Note:** Some environment variables listed here are personally made by myself, so they will not appear on the referenced sites.

## Recommended DE Setup

### 1. Auto-update development environments using MSYS2

Some people (including me) are lazy to download new version of development environment everytime a new update was released. Luckily there is [MSYS2](https://www.msys2.org/) that will do all these updates for you by just inputting a single command (`pacman -Syu`), and it is portable too! Assuming that you have 64 bit OS, you can download it (`.tar` format) from SourceForge [here](https://sourceforge.net/projects/msys2/files/Base/x86_64/).

1. Extract the downloaded MSYS2 to a short path, for example: `C:\MSYS64`
2. Run `msys2_shell.bat` inside the folder (`C:\MSYS64` is the root folder, so it should be `C:\MSYS64\msys2_shell.bat`)
3. Restart MSYS:
    * Close MSYS2 by clicking Windows close button (don't type `exit`!)
    * Run `msys2_shell.bat` again
4. Inside MSYS2 shell, type `pacman -Syu` and enter
5. Repeat step 3-4 until all packages are up to date (MSYS2 will say `there is nothing to do`)
6. Install the packages you want. For example:
    * MinGW (64 bit): `pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-gdb`
    * Python (64 bit): `pacman -S mingw-w64-x86_64-python3 mingw-w64-x86_64-python3-pip`
7. Change both `MINGW` and `PYTHON` values inside `VSCodePortable.ini` to `C:\MSYS64\mingw64`
8. Start `VSCodePortable.exe`, both of them will now be detected if the paths are correct

**Note:** MSYS2 packages may have different folder structures compared to native packages, I only test a few packages!

### 2. Other sources for downloading portable development environment

In case you want to do it the hard way (aka manual update), here are some alternative sources that I personally use (I'm also open for suggestions):

|Source|Description|
|-|-|
|[WinLibs](https://winlibs.com/)|Provides up-to-date GCC for Windows, faster than [Mingw-w64](https://www.mingw-w64.org/) (which is incredibly slow at releasing updates)|
|[Nuwen.net](https://nuwen.net/mingw.html)|May not always provides the latest version of GCC, but you can select only the components you need (smaller overall size)|
|[Adoptium](https://adoptium.net/temurin/releases/)|Provides open-source version of (Java) JDK and JRE. Formerly known as [AdoptOpenJDK](https://adoptopenjdk.net/releases.html)|
|[Red Hat OpenJDK](https://developers.redhat.com/products/openjdk/download)|More or less the same as above, but provided by Red Hat
|[WinPython](https://winpython.github.io/)|Provides portable installer for Python. This is great since the official Python installer usually can't be extracted properly using workarounds (see below).|
|[MinGit](https://github.com/git-for-windows/git/releases)|Absolute minimal Git directly from the official repo (see [wiki](https://github.com/git-for-windows/git/wiki/MinGit)), even smaller than the portable installer|
|...|For other development environments that are not listed here (e.g. Node.js, Go, Rust), you can usually extract the files from installer using 7-Zip, Universal Extractor 2, or Sandboxie-Plus. Note: Try searching for `.zip` or `.tar` release first before relying on those programs!|

# License

* VSCodePortable under the [GPL v2.0 license](https://github.com/AndhikaWB/VSCodePortable/blob/master/LICENSE)
* PortableApps.com Launcher under the [GPL v2.0 license](https://github.com/AndhikaWB/VSCodePortable/blob/master/LICENSE)
* Visual Studio Code under Microsoft custom [license](https://code.visualstudio.com/license)
