# Define the folder and file paths
$folderPath = "C:\IT_Folder"
$filePath = "$folderPath\set_chrome_default.reg"

# Create the folder if it doesn't exist
if (-Not (Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath
}

# Download the MSI file
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/francisuadm/chrome/main/set_chrome_default.reg" -OutFile $filePath

# Install the MSI file
Start-Process regedit.exe -ArgumentList "/s", $filePath -Wait
