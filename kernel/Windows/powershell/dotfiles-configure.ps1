#!/usr/bin/env powershell

Import-Module  "~/.dotfiles/bin/dotfiles.psm1" -ErrorAction Stop

Set-DotfilesModuleLink -src "powershell/PSConfiguration.symlink.ps1" -dst ~/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
Set-DotfilesModuleLink -src "powershell/PSConfiguration.symlink.ps1" -dst ~/Documents/WindowsPowerShell/Microsoft.VSCode_profile.ps1
