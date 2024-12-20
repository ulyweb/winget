# Prompt for the domain and username
$domain = Read-Host "Enter domain"
$username = Read-Host "Enter username"
$fullUsername = "$domain\$username"

# Run the command with the specified user
Start-Process -FilePath "powershell.exe" -ArgumentList "-Command `"Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command `"dsa.msc`"' -Verb RunAs`"" -Credential $fullUsername
