> [!NOTE]
> # Chrome Browser
## ***_<sub>How to force sync-up and update</sup>_***
<!-- TO DO: add more details about me later -->

#### Open command prompt as admin, then copy and paste the command below:

```
reg add "HKLM\SOFTWARE\Policies\Google\Update" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Google\Update" /v "Install{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Google\Update" /v "Update{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome" /v "SyncDisabled" /t REG_DWORD /d 0 /f

```


> [!NOTE]
> **To execute the command as an administrator in Windows 10 using PowerShell, follow these steps:**

> [!IMPORTANT]
> Open ***`PowerShell`*** as Administrator:

> [!TIP]
> Press ***`Win + X`*** and select Windows PowerShell (Admin) from the menu.

> [!IMPORTANT]
> Run the Command:

> [!TIP]
> Copy and paste the following command into the ***`PowerShell`*** window and press Enter:
> ```
> iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/chromeupdate.ps1 | iex
> ```

### Try this one, by using ***`Win + R`*** then copy and paste command below:

```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/chromeupdate.ps1 | iex\"' -Verb RunAs"
```


### Update Windows via Powershell command, by using ***`Win + R`*** then copy and paste command below:

```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/PSWindowsUpdate.ps1 | iex\"' -Verb RunAs"
```

### Install Winget 

```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/Installer_Winget.ps1 | iex\"' -Verb RunAs"
```




### Poly Lens Desktop installation
<!--- powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"Invoke-WebRequest -Uri https://swupdate.lens.poly.com/lens-desktop-windows/1.4.0/1.4.0/PolyLens-1.4.0.msi -OutFile C:\it_folder\PolyLens-1.4.0.msi; Start-Process msiexec.exe -ArgumentList \"/i C:\it_folder\PolyLens-1.4.0.msi /quiet /norestart ALLUSERS=1\" -Wait -NoNewWindow\"' -Verb RunAs" --->
```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/add-Poly.ps1 | iex\"' -Verb RunAs"
```

### Installation Displaylink
```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"winget install --id DisplayLink.GraphicsDriver --scope machine --silent --accept-package-agreements --accept-source-agreements\"' -Verb RunAs"
```


### Set default app Chrome Browser for all users
```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/Set-ChromeDefault.ps1 | iex\"' -Verb RunAs"
```


### PowerShell script to export/import Chrome bookmarks
```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/Manage-ChromeBookmarks.ps1 | iex\"' -Verb RunAs"
```

### PowerShell script to backup/restore Wi-Fi connectivities
```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/Manage-WifiProfiles.ps1 | iex\"' -Verb RunAs"
```

### PowerShell script to execute a PowerShell command with another user account
```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/runas_prompt.ps1 | iex\"' -Verb RunAs"
```

### Run Active Directory User and Computers as Admin
```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/AD_as_A_Account.ps1 | iex\"' -Verb RunAs"
```
