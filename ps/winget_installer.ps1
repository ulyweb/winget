# PowerShell script to install winget on Windows 10

# Set the URL for the App Installer package
$appInstallerUrl = 'https://aka.ms/Microsoft.Store.AppInstaller'

# Define the path to save the downloaded package
$downloadPath = "$env:TEMP\AppInstaller.appxbundle"

# Download the App Installer package
Invoke-WebRequest -Uri $appInstallerUrl -OutFile $downloadPath

# Install the App Installer package
Add-AppxPackage -Path $downloadPath

# Confirm the installation
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Output 'winget was installed successfully.'
} else {
    Write-Output 'winget installation failed.'
}
