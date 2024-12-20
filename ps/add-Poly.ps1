# Define the folder and file paths
$folderPath = "C:\IT_Folder"
$filePath = "$folderPath\PolyLens-1.5.0.msi"

# Create the folder if it doesn't exist
if (-Not (Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath
}

# Download the MSI file
Invoke-WebRequest -Uri "https://swupdate.lens.poly.com/lens-desktop-windows/1.5.0/1.5.0/PolyLens-1.5.0.msi" -OutFile $filePath

# Install the MSI file
Start-Process msiexec.exe -ArgumentList "/i $filePath /quiet /norestart ALLUSERS=1" -Wait -NoNewWindow
