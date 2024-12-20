# This script requires Run as Administrator
# Save this script as Manual_PSwindowsupdate.ps1

# Function to check for Administrator privileges
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check for Administrator privileges
if (-not (Test-Administrator)) {
    Write-Host "This script requires running as Administrator."
    exit
}

# Set Execution Policy
try {
    Set-ExecutionPolicy RemoteSigned -Force
    Write-Host "Execution policy set to RemoteSigned."
} catch {
    Write-Host "Failed to set execution policy: $_"
    exit
}

# Install PSWindowsUpdate Module
Install-Module PSWindowsUpdate -Force
Write-Host "PSWindowsUpdate module installed successfully."

# Import the Module
Import-Module PSWindowsUpdate
Write-Host "PSWindowsUpdate module imported successfully."

# Check for Available Updates
$updates = Get-WindowsUpdate
Write-Host "Available updates checked successfully."

# Install Updates
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
Write-Host "Updates installed successfully."

# Pause to ensure the script waits for user input before closing
Write-Host "Press any key to exit..."
[System.Console]::ReadKey() | Out-Null
