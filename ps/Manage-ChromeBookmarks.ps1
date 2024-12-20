# Set the paths
$exportPath = "C:\IT_folder\favorites"
$importPath = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default"

# Create the export directory if it doesn't exist
if (-not (Test-Path -Path $exportPath)) {
    New-Item -Path $exportPath -ItemType Directory
}

# Function to export Chrome bookmarks with timestamp
function Export-Bookmarks {
    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $backupFile = "$exportPath\Bookmarks_$timestamp.bak"
    
    if (Test-Path "$importPath\Bookmarks") {
        Write-Host "Exporting Chrome bookmarks..."
        Copy-Item -Path "$importPath\Bookmarks" -Destination $backupFile -Force
        Write-Host "Bookmarks exported to $backupFile"
    } else {
        Write-Host "No bookmarks file found to export."
    }
}

# Function to import Chrome bookmarks
function Import-Bookmarks {
    # List available backup files
    $backupFiles = Get-ChildItem -Path $exportPath -Filter "Bookmarks_*.bak" | Sort-Object LastWriteTime -Descending
    
    if ($backupFiles.Count -eq 0) {
        Write-Host "No backup files available for import."
        return
    }
    
    # Display the list of backup files
    Write-Host "Available backup files:"
    for ($i = 0; $i -lt $backupFiles.Count; $i++) {
        Write-Host "$($i + 1). $($backupFiles[$i].Name)"
    }
    
    # Prompt for selection
    $choice = Read-Host "Enter the number of the backup file to import"

    if ($choice -match '^\d+$' -and [int]$choice -le $backupFiles.Count -and [int]$choice -ge 1) {
        $selectedFile = $backupFiles[[int]$choice - 1].FullName
        Write-Host "Importing Chrome bookmarks from $selectedFile..."
        Copy-Item -Path $selectedFile -Destination "$importPath\Bookmarks" -Force
        Write-Host "Bookmarks imported successfully."
    } else {
        Write-Host "Invalid choice. Please enter a valid number."
    }
}

# Function to display the menu and handle user choices
function Show-Menu {
    while ($true) {
        Write-Host ""
        Write-Host "1. Export Chrome bookmarks"
        Write-Host "2. Import Chrome bookmarks"
        Write-Host "3. Exit"
        $choice = Read-Host "Enter your choice (1, 2, or 3)"

        switch ($choice) {
            1 { Export-Bookmarks }
            2 { Import-Bookmarks }
            3 { Write-Host "Exiting..."; break }
            default { Write-Host "Invalid choice. Please enter 1, 2, or 3." }
        }
    }
}

# Show menu
Show-Menu

# End script
Write-Host "Goodbye!"
