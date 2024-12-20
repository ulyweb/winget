# <img src="https://github.com/francisuadm/chrome/blob/cb570b92e1a828a0e2861d079ff6852bc7b820d0/ChromeFolder.png" width="86" height="86" orientation="180" > **Chrome Browser**
<!--
## ***_<sub>How to force sync-up update</sup>_***
 TO DO: add more details about me later -->


> [!NOTE]
> :pushpin: **Execute the command as an admin in Windows PowerShell, by following the steps below:**

> [!TIP]
> :desktop_computer: Press   ****<img src="https://github.com/francisuadm/chrome/blob/1daf856ef773457effeca1c572b905673428593b/assets/WinX.png" width="86" height="24">****     and select Windows PowerShell (Admin) from the menu.
> 
> > > :scissors: ***press the copy button below and, :pencil: paste the command into the ***`PowerShell`*** window and press enter:***
> 
> ```
> powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/chromeupdate.ps1 | iex\"' -Verb RunAs"
> ```


> > > ##### Run Active Directory User and Computers as Admin.
```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/AD_as_A_Account.ps1 | iex\"' -Verb RunAs"
```

> > > ##### Run PowerShell command another user account.
```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/runas_prompt.ps1 | iex\"' -Verb RunAs"
```

> > > ##### Backup/Restore Wi-Fi connectivities
```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/Manage-WifiProfiles.ps1 | iex\"' -Verb RunAs"
```

> > > ##### Export/Import Chrome bookmarks
```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/Manage-ChromeBookmarks.ps1 | iex\"' -Verb RunAs"
```

