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
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/Installer_Winget1.ps1 | iex\"' -Verb RunAs"
````

#### Dell Command | update

````
winget install Dell.CommandUpdate  --scope machine --disable-interactivity --force -h
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
