# <img src="https://github.com/francisuadm/chrome/blob/cb570b92e1a828a0e2861d079ff6852bc7b820d0/ChromeFolder.png" width="86" height="86" orientation="180" > **Winget command**
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
> > > ##### Enable Winget the App Installer

```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/runEAInstaller.ps1 | iex\"' -Verb RunAs"
```


```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/runEAInstaller1.ps1 | iex\"' -Verb RunAs"
```

```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/DisableSystemReg.ps1 | iex\"' -Verb RunAs"
```

### mydailytask

```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iwr -useb https://raw.githubusercontent.com/francisuadm/chrome/main/ps/task.ps1 | iex\"' -Verb RunAs"
```


> ### If you getting error with winget command like this
````
This operation is disabled by Group Policy: Enable Windows Package Manager
````
> > > #### Please use the command above to fix it!
