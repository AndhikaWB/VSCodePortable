# VSCodePortable
Visual Studio Code in [PortableApps.com](https://portableapps.com/) format (unofficial). Can also be applied to VSCodium.

# Wait what?
* Why do I need it if Visual Studio Code supported [portable mode](https://code.visualstudio.com/docs/editor/portable) out-of-the-box?

  Well.. Yes, Visual Studio Code supported portable mode out-of-the-box, where its data will be stored on `Data` folder (on the same directory where `Code.exe` exist). Unfortunately, it's not enough, they still leave some traces on the system and the registry if you check it carefully (although the total may be less than 1 MB).
  
  Moreover, just because Visual Studio Code is portable, it doesn't mean that they support portable development environment out-of-the-box. You may need to add them to `PATH` manually and sometimes, this process is tiring, especially if you want to set them on multiple computer (or need to change the `PATH` oftenly).

* What are the differences compared to native portable mode?
  * All traces left (on the system and registry) by Visual Studio Code will be removed after run. Some extensions can also leave traces on the system and registry, I can't do anything about it. However, you can add them to `VSCodePortable.ini` so they can be removed automatically later.
  * Most of the important system path variable are virtualized (this include `USERPROFILE`, `APPDATA`, `LOCALAPPDATA`, and `PROGRAMDATA`). So even Visual Studio Code or their extensions will usually write its data on VSCodePortable `Data` folder. Meaning that no changes are made to the system, and you can simply copy VSCodePortable to your portable drive.
  * Support for 4 development environments by default (this include MinGW, Python, Java, and Git). You can also add many others by modifying the launcher config file. They will be added to `PATH` during runtime, but not globally (only affect `Code.exe` and processes run by it).
  * Added context menu items (`Open with Code`) just like the non-portable version. Of course, they will be removed after you close Visual Studio Code.
  
# How to use?

### Initial steps
The first thing you probably want to do after downloading VSCodePortable.

1. Download the latest [release](https://github.com/AndhikaWB/VSCodePortable/releases) of VSCodePortable
2. Extract it anywhere (please avoid using long path). For example, `D:\Apps\VSCodePortable` (where `VSCodePortable.exe` must exist)
2. Download Visual Studio Code (`.zip` format) from [here](https://code.visualstudio.com/#alt-downloads)
3. Extract it to `D:\Apps\VSCodePortable\App\VSCode` (where `Code.exe` must exist)

### Setting-up development environment
Required to make Visual Studio Code recognize your (portable) development environment. MinGW, Python, Java, and Git are supported by default. Your development environment must be downloaded first (and placed somewhere on the disk). They will be appended to `PATH` before launching Visual Studio Code and will be removed from `PATH` afterward.

1. Navigate to `D:\Apps\VSCodePortable\App\AppInfo\Launcher`
2. Open `VSCodePortable.ini` by using any text editor
3. Look out for the `[Environment]` section and change `GIT_ROOT`/`MINGW_ROOT`/`PYTHON_ROOT`/`JAVA_ROOT`/`CUSTOM_ROOT` variable to the real path where your development environment exist (please don't point to the `bin` folder directly). If the folder/path doesn't exist, it will be simply ignored
4. Done, if you change it to the right path, Visual Studio Code will now recognize your (portable) development environment (because they are appended to the `PATH` variable before launch)
5. If you are still unsure, you can type `echo %PATH%` on Visual Studio Code terminal and check it by yourself. Or by simply running their executable (example: `gcc --version`, `python --version`) inside the terminal

### Adding unsupported development environment
Since only MinGW, Python, Java, and Git that are supported by default. You may want to add other development environment(s). You may want to take a look at `Custom.nsh` (tested) or by adding `PATH=%PATH%;PathToYourDE` on the `[Environment]` section of `VSCodePortable.ini` (not tested).

Please note that after changing the `Custom.nsh` file, you will need to recompile `VSCodePortable.exe` for the changes to be made (no need to recompile `VSCodePortable.exe` if you're only changing `VSCodePortable.ini`). You will need to download PortableApps.com Launcher Generator first from [here](https://portableapps.com/apps/development/portableapps.com_launcher) to recompile `VSCodePortable.exe`.

# Some tips

### Lazy to update your portable development environment(s)?
Some people (including me) will be tired if they need to download the new (portable version of) development environment everytime a new update was released. Luckily there is [MSYS2](https://www.msys2.org/) that will do all these updates for you by just inputting a single command (`pacman -Syu`), and it is portable too! Make sure to download the `tar.xz` version from SourceForge [here](https://sourceforge.net/projects/msys2/files/Base/x86_64/).

### Supported environment variables
Assuming that you installed VSCodePortable on `D:\Apps\VSCodePortable` (where `VSCodePortable.exe` exist), here is some useful environment variable paths for you:

* Only read by `VSCodePortable.exe`:
  * `PAL:DataDir` : `D:\Apps\VSCodePortable\Data`
  * `PAL:AppDir` : `D:\Apps\VSCodePortable\App`
  * `PAL:LauncherDir` : `D:\Apps\VSCodePortable`
  * `PAL:LauncherPath` : `D:\Apps\VSCodePortable\VSCodePortable.exe`
  * `PAL:LauncherFile` : `VSCodePortable.exe`
  * `PAL:PortableAppsDir` : `D:\Apps`
  * `PAL:CommonFilesDir` : `D:\Apps\CommonFiles`

* Only read by `Code.exe` and processes run by it:
  * `UserProfile` : `C:\User\YourUserName` (virtualized to `%PAL:DataDir%\Virtual`)
  * `AppData` : `C:\User\YourUserName\AppData\Roaming` (virtualized to `%PAL:DataDir%\Virtual\AppData\Roaming`)
  * `LocalAppData` : `C:\User\YourUserName\AppData\Local` (virtualized to `%PAL:DataDir%\Virtual\AppData\Local`)
  * `LocalAppDataLow` : `C:\User\YourUserName\AppData\LocalLow` (can't be virtualized)
  * `ProgramData` : `C:\ProgramData` (virtualized to `%PAL:DataDir%\Virtual\ProgramData`)
  * `ComSpec` : `C:\Windows\System32\cmd.exe`
  * `SystemDrive` : `C:`
  * And many more from [here](https://ss64.com/nt/syntax-variables.html)
  
Good luck!
