#!/usr/bin/env powershell

if (Get-Command choco -errorAction SilentlyContinue) {
    Write-Verbose "Skipping chocolatey install."
}
else {
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials; 
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

