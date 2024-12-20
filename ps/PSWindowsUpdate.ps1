# This script requires Run as Administrator
# Save this script as windowsupdate.ps1

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
try {
    Install-Module PSWindowsUpdate -Force
    Write-Host "PSWindowsUpdate module installed successfully."
} catch {
    Write-Host "Failed to install PSWindowsUpdate module: $_"
    exit
}

# Import the Module
try {
    Import-Module PSWindowsUpdate
    Write-Host "PSWindowsUpdate module imported successfully."
} catch {
    Write-Host "Failed to import PSWindowsUpdate module: $_"
    exit
}

# Check for Available Updates
try {
    $updates = Get-WindowsUpdate
    Write-Host "Available updates checked successfully."
} catch {
    Write-Host "Failed to check for available updates: $_"
    exit
}

# Install Updates
try {
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
    Write-Host "Updates installed successfully."
} catch {
    Write-Host "Failed to install updates: $_"
    exit
}

# Pause to ensure the script waits for user input before closing
Write-Host "Press any key to exit..."
[System.Console]::ReadKey() | Out-Null
