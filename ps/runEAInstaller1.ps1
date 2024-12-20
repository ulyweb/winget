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
# URLs for the App Installer dependencies
$appInstallerUrl = "https://raw.githubusercontent.com/francisuadm/chrome/main/ps/EnableAppInstaller.bat"

# Download folder location
$appInstallerPath = "C:\IT_Folder\EnableAppInstaller.bat"

# Download the packages
Download-File -url $appInstallerUrl -output $appInstallerPath

# Run the batch file with elevated privileges
Start-Process -FilePath $appInstallerPath -Verb RunAs
