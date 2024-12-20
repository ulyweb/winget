# Clear the host display
Clear-Host

# Remove any existing PowerShell sessions
Get-PSSession | Remove-PSSession

# Clear the host display again
Clear-Host

function Show-Menu {
    param (
        [string]$title = 'Menu'
    )
    Write-Host "====================="
    Write-Host " $title"
    Write-Host "====================="
    Write-Host "1: Export Signatures"
    Write-Host "2: Restore Signatures"
    Write-Host "0: Exit"
}

function Export-Signatures {
    # Define the source and destination paths for export
    $sourcePath = "$env:USERPROFILE\AppData\Roaming\Microsoft"
    $exportDestinationPath = "C:\IT_folder\Signatures"

    # Check if the export destination folder exists, if not, create it
    if (-Not (Test-Path -Path $exportDestinationPath)) {
        New-Item -ItemType Directory -Path $exportDestinationPath -Force
    }

    # Copy the Signatures folder to the export destination
    Copy-Item -Path "$sourcePath\Signatures" -Destination $exportDestinationPath -Recurse

    Write-Output "The Signatures folder has been backed up to $exportDestinationPath"
}

function Restore-Signatures {
    # Define the source and destination paths for restore
    $restoreSourcePath = "C:\IT_folder\Signatures"
    $restoreDestinationPath = "$env:USERPROFILE\AppData\Roaming\Microsoft"

    # Check if the restore destination folder exists, if not, create it
    if (-Not (Test-Path -Path $restoreDestinationPath)) {
        New-Item -ItemType Directory -Path $restoreDestinationPath -Force
    }

    # Copy the Signatures folder to the restore destination
    Copy-Item -Path "$restoreSourcePath\*" -Destination $restoreDestinationPath -Recurse

    Write-Output "The Signatures folder has been restored to $restoreDestinationPath"
}

function Main {
    do {
        Show-Menu -title 'Outlook Signatures Management'
        $choice = Read-Host 'Enter your choice'

        switch ($choice) {
            1 { Export-Signatures }
            2 { Restore-Signatures }
            0 { Write-Host 'Exiting...'; break }
            default { Write-Host 'Invalid choice, please try again.' }
        }
    } while ($choice -ne 0)
}

# Run the main function
Main
