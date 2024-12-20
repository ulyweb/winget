### To install the Poly Lens Desktop app for all users on a Windows 10 computer, you can use PowerShell to run the MSI installer with administrative privileges. 

Here's how you can do it:

1. **Download the MSI file**:
   First, download the MSI file from the provided link:
<!-- Invoke-WebRequest -Uri "https://swupdate.lens.poly.com/lens-desktop-windows/1.4.0/1.4.0/PolyLens-1.4.0.msi" -OutFile "C:\IT_Folder\PolyLens-1.4.0.msi" -->

   ```powershell
   iwr -Uri "https://swupdate.lens.poly.com/lens-desktop-windows/1.4.0/1.4.0/PolyLens-1.4.0.msi" -OutFile "C:\IT_Folder\PolyLens-1.4.0.msi"
   ```

3. **Install the MSI file for all users**:
   Use the `msiexec` command to install the MSI file for all users. Run the following PowerShell command with administrative privileges:
   ```powershell
   Start-Process msiexec.exe -ArgumentList "/i C:\IT_Folder\PolyLens-1.4.0.msi /quiet /norestart ALLUSERS=1" -Wait -NoNewWindow
   ```

`C:\IT_Folder\PolyLens-1.4.0.msi` with the actual path where you saved the MSI file.

This will install the Poly Lens Desktop app for all users on the computer. 




```
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"Invoke-WebRequest -Uri https://swupdate.lens.poly.com/lens-desktop-windows/1.4.0/1.4.0/PolyLens-1.4.0.msi -OutFile C:\it_folder\PolyLens-1.4.0.msi; Start-Process msiexec.exe -ArgumentList \"/i C:\it_folder\PolyLens-1.4.0.msi /quiet /norestart ALLUSERS=1\" -Wait -NoNewWindow\"' -Verb RunAs"
```


Manually download Poly Lens
```
https://lens.poly.com/download
```
