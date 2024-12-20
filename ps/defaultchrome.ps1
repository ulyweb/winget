
# Define the registry paths for HTTP and HTTPS associations
$httpKey = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
$httpsKey = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice"

# Set the default browser to Chrome for HTTP and HTTPS
Set-ItemProperty -Path $httpKey -Name "ProgId" -Value "ChromeHTML" -Force
Set-ItemProperty -Path $httpsKey -Name "ProgId" -Value "ChromeHTML" -Force

# Apply the changes for all users
$users = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false }
foreach ($user in $users) {
    $sid = $user.SID
    $userHttpKey = "Registry::HKEY_USERS\$sid\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
    $userHttpsKey = "Registry::HKEY_USERS\$sid\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice"
    
    Set-ItemProperty -Path $userHttpKey -Name "ProgId" -Value "ChromeHTML" -Force
    Set-ItemProperty -Path $userHttpsKey -Name "ProgId" -Value "ChromeHTML" -Force
}
