# winget




### Allow to use winget command

````
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" /v EnableExperimentalFeatures /t REG_DWORD /d 1 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" /v EnableAppInstaller /t REG_DWORD /d 1 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" /v EnableHashOverride /t REG_DWORD /d 1 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" /v EnableMSAppInstallerProtocol /t REG_DWORD /d 1 /f
````

#### Let's install winget to Windows 10/11
````
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/ulyweb/winget/refs/heads/main/ps/Installer_Winget1.ps1 | iex\"' -Verb RunAs"
````

#### Dell Command | update

````
winget install Dell.CommandUpdate  --scope machine --force
````


#### DisplayLink

````
winget install DisplayLink.GraphicsDriver --scope machine --force
````

####  Intel Driver & Support Assistant

````
winget install Intel.IntelDriverAndSupportAssistant
````



#### Alternative to Snagit

````
winget install Greenshot.Greenshot  --scope machine --disable-interactivity --force -h
````


#### CPUID

````
winget install --id CPUID.CPU-Z --scope machine --disable-interactivity --force -h
````

#### OBS Studio

````
winget install --id OBSProject.OBSStudio --scope machine --disable-interactivity --force -h
````

#### No Machine Remote Tools

````
winget install NoMachine.NoMachine --scope machine --force
````


#### Remote Connections & Passwords. Everywhere!

````
winget install Devolutions.RemoteDesktopManager --force
````

#### Yazi and FZF | **Github Installation Website** => [Yazi and FZF](https://yazi-rs.github.io/docs/installation)
````
winget install sxyazi.yazi
# Install the optional dependencies (recommended):
winget install Gyan.FFmpeg 7zip.7zip jqlang.jq sharkdp.fd BurntSushi.ripgrep.MSVC junegunn.fzf ajeetdsouza.zoxide ImageMagick.ImageMagick
````

#### Resource monitor that shows usage and stats

````
winget install aristocratos.btop4win --scope machine --force
````


####  To upgrade all installed packages on your system through PowerShell.

````
winget upgrade --all --force --silent
````

### TrafficMonitor

````
winget install --id=zhongyang219.TrafficMonitor.Full -e --scope machine --force
````

#### After the installation for Traffic Monitor close the window

#### now to launch it, type in: TrafficMonitor
