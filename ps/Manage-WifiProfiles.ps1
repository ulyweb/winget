# Define the directory to store the wireless profiles
$basePath = "C:\IT_Folder"

# Function to generate a unique folder path based on the current date and time
function Get-UniqueFolderPath {
    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $folderPath = "$basePath\Wireless_$timestamp"
    return $folderPath
}

# Function to export all wireless profiles
function Export-WifiProfiles {
    $folderPath = Get-UniqueFolderPath
    # Create the export directory
    New-Item -Path $folderPath -ItemType Directory -Force
    Write-Host "Exporting all wireless profiles to $folderPath..."
    netsh wlan export profile folder=$folderPath key=clear
    Write-Host "All profiles have been exported successfully to $folderPath."
}

# Function to import wireless profiles from a list of available backup files
function Import-WifiProfiles {
    # List available backup folders
    $backupFolders = Get-ChildItem -Path $basePath -Directory | Where-Object { $_.Name -match '^Wireless_\d{8}_\d{6}$' } | Sort-Object LastWriteTime -Descending
    
    if ($backupFolders.Count -eq 0) {
        Write-Host "No backup folders available for import."
        return
    }
    
    # Display the list of backup folders
    Write-Host "Available backup folders:"
    for ($i = 0; $i -lt $backupFolders.Count; $i++) {
        Write-Host "$($i + 1). $($backupFolders[$i].FullName)"
    }
    
    # Prompt for selection
    $choice = Read-Host "Enter the number of the backup folder to import from"
    
    if ($choice -match '^\d+$' -and [int]$choice -le $backupFolders.Count -and [int]$choice -ge 1) {
        $selectedFolder = $backupFolders[[int]$choice - 1].FullName
        Write-Host "Importing profiles from $selectedFolder..."
        
        $files = Get-ChildItem -Path $selectedFolder -Filter "*.xml"
        
        if ($files.Count -eq 0) {
            Write-Host "No profile files found to import."
            return
        }
        
        foreach ($file in $files) {
            Write-Host "Importing profile $($file.Name)..."
            netsh wlan add profile filename=$file.FullName user=all
        }
        
        Write-Host "SSID profiles imported successfully."
    } else {
        Write-Host "Invalid choice. Please enter a valid number."
    }
}

# Function to display the menu and handle user choices
function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "Please select what you would like to do:"
        Write-Host "1. Export current wireless SSID"
        Write-Host "2. Import wireless SSID"
        Write-Host "3. Exit"
        Write-Host ""
        $choice = Read-Host "Enter your choice (1, 2, or 3)"
        
        switch ($choice) {
            1 { Export-WifiProfiles }
            2 { Import-WifiProfiles }
            3 { Write-Host "Exiting..."; break }
            default { Write-Host "Invalid choice, please choose 1, 2, or 3." }
        }
        
        if ($choice -eq "3") { break }
        Read-Host "Press Enter to return to the menu"
    }
}

# Show menu
Show-Menu

# End script
Write-Host "Goodbye!"
