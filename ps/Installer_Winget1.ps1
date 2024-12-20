# Function to download a file from a URL
function Download-File {
    param (
        [string]$url,
        [string]$output
    )
    try {
        Invoke-WebRequest -Uri $url -OutFile $output -ErrorAction Stop
        Write-Output "Downloaded $url to $output"
    } catch {
        Write-Output "Failed to download $url"
        throw
    }
}
# Check if c:\IT_folder directory exists, if not, create it
$DestPath = "C:\IT_folder"
if (-not (Test-Path -Path $DestPath)) {
    New-Item -ItemType Directory -Path $DestPath
}


# URLs for the App Installer dependencies (x64 architecture)
$vcLibsUrl = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
$frameworkUrl = 'https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6'
$appInstallerUrl = 'https://github.com/microsoft/winget-cli/releases/download/v1.8.1911/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'

# Paths to save the downloaded packages
# $vcLibsPath = "$env:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx"
# $frameworkPath = "$env:TEMP\Microsoft.UI.Xaml.2.8.6.nupkg"
# $appInstallerPath = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$vcLibsPath = "$DestPath\Microsoft.VCLibs.x64.14.00.Desktop.appx"
$frameworkPath = "$DestPath\Microsoft.UI.Xaml.2.8.6.nupkg.zip"
$appInstallerPath = "$DestPath\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"



# Download the packages
Download-File -url $vcLibsUrl -output $vcLibsPath
Download-File -url $frameworkUrl -output $frameworkPath
Download-File -url $appInstallerUrl -output $appInstallerPath

# Extract the .appx file from the .zip
Expand-Archive -Path "$DestPath\Microsoft.UI.Xaml.2.8.6.nupkg.zip" -DestinationPath "$DestPath\Microsoft.UI.Xaml.2.8.6"
$extractedFrameworkPath = "$DestPath\Microsoft.UI.Xaml.2.8.6\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.8.appx"

# Check if the files exist before attempting to install them
if (Test-Path $vcLibsPath) {
    Write-Output "VCLibs package exists at $vcLibsPath"
    if (Test-Path $extractedFrameworkPath) {
        Write-Output "Framework package exists at $extractedFrameworkPath"
        if (Test-Path $appInstallerPath) {
            Write-Output "App Installer package exists at $appInstallerPath"
            # Install the dependencies
            try {
                Add-AppxPackage -Path $vcLibsPath # -ErrorAction Stop
                Write-Output "Installed VCLibs package"
            } catch {
                Write-Output "Failed to install VCLibs package"
                throw
            }
            try {
                Add-AppxPackage -Path $extractedFrameworkPath # -ErrorAction Stop
                Write-Output "Installed Framework package"
            } catch {
                Write-Output "Failed to install Framework package"
                throw
            }
            try {
                Add-AppxPackage -Path $appInstallerPath # -ErrorAction Stop
                Write-Output "Installed App Installer package"
            } catch {
                Write-Output "Failed to install App Installer package"
                throw
            }

            # Confirm the installation
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                Write-Output 'winget was installed successfully.'
            } else {
                Write-Output 'winget installation failed.'
            }
        } else {
            Write-Output 'The App Installer package failed to download.'
        }
    } else {
        Write-Output 'The framework package failed to download.'
    }
} else {
    Write-Output 'The VCLibs package failed to download.'
}
