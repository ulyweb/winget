cd c:\IT_Folder\
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile C:\IT_Folder\Desktop.appx
Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6 -OutFile C:\IT_Folder\UI.Xaml.2.8.6.nupkg.zip
Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.8.1911/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile C:\IT_Folder\DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Add-AppxPackage -Path .\Desktop.appx
Expand-Archive -Path .\UI.Xaml.2.8.6.nupkg.zip -DestinationPath C:\IT_Folder\UI.Xaml.2.8.6
Add-AppxPackage -Path C:\IT_Folder\UI.Xaml.2.8.6\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.8.appx
Add-AppxPackage -Path C:\IT_Folder\DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
winget





“No applicable app licenses found” error when trying to run winget. This issue can occur if the necessary app licenses are not properly installed or recognized by the system.

This this to resolve this issue:

Download the license file from this link.
https://github.com/microsoft/winget-cli/releases/download/v1.0.11692/08d8788d59cf47ed9bf42c31e31f8efa_License1.xml

Install the License File:
Use the Add-AppxProvisionedPackage command to add the license file to your system. Run the following command in PowerShell:
Add-AppxProvisionedPackage -Online -PackagePath "C:\IT_Folder\08d8788d59cf47ed9bf42c31e31f8efa_License1.xml" -LicensePath "C:\IT_Folder\08d8788d59cf47ed9bf42c31e31f8efa_License1.xml"

Reinstall the Packages:
Ensure that all the necessary packages are installed correctly. You can use the following commands:
Add-AppxPackage -Path C:\IT_Folder\Desktop.appx
Add-AppxPackage -Path C:\IT_Folder\UI.Xaml.2.8.6\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.8.appx
Add-AppxPackage -Path C:\IT_Folder\DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
