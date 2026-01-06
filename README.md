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

#### Good Text Editor Pro

````
winget install --id LasseMarkusRautiainen.TextEditorPro --scope machine --force -e
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

> [!NOTE]
> ### Open Local Users & Groups
> > #### **Runs PowerShell as A-Admin from Windows Run command (Win+R)**

````
RunAs /noprofile /user:%USERDOMAIN%\a-[REPLACE with UserName] "powershell \"Start-Process mmc \" -Verb RunAs"
````


#### or manual way with powershell command

````
RunAs /noprofile /user:%USERDOMAIN%\a-[REPLACE with UserName] "powershell \"Start-Process powershell \" -Verb RunAs"
````


> [!NOTE]
> ### Using Start-BitsTransfer
> > #### The BITS (Background Intelligent Transfer Service) module is a robust,
> > #### built-in Windows component designed for resilient file transfers,
> > #### especially in scenarios with network interruptions.
> > This is often the most reliable method for larger files.

````
Import-Module BitsTransfer

$sourceUrl = 'https://github.com/microsoft/winget-cli/releases/download/v1.11.430/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
$destinationPath = 'C:\Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
Start-BitsTransfer -Source $sourceUrl -Destination $destinationPath
````




> [!NOTE]
> ### Running the Installer Remotely
> > #### Once you've confirmed a successful download on the remote machine,
> > #### you can run the installer using Add-AppxPackage via Invoke-Command,
> > #### just as described in the previous response.

````
Invoke-Command -ComputerName 'Remote-PC-Name' -ScriptBlock {
    # Assuming the file is already downloaded and verified
    $filePath = 'C:\Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
    
    try {
        Add-AppxPackage -Path $filePath
        Write-Host "Installation successful."
    } catch {
        Write-Host "Installation failed: $($_.Exception.Message)"
    }
}
````
