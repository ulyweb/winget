# Define the username to be added to the Administrators group
$domain = Read-Host "Enter domain"
$username = Read-Host "Enter username"
$fullUsername = "$domain\$username"


# Add the user to the Administrators group
Add-LocalGroupMember -Group "Administrators" -Member $fullUsername
