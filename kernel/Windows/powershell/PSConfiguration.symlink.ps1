#!/usr/bin/env powershell

Import-Module  "~/.dotfiles/bin/dotfiles.psm1" -ErrorAction Stop

Set-Alias show Get-ChildItem

# source global files: PSConfiguration-global.ps1
Get-DotfilesModuleNames | ForEach-Object {
    $m = $_
    Get-DotfilesProfiles | ForEach-Object {
        $p = $_
        foreach ($f in @("PSConfiguration-global.ps1")) {
            if (Test-Path -Path "$p/$m/$f") {
                Write-Debug "source $p/$m/$f"
                . "$p/$m/$f"
            }
        }
    }
}

# source best maching files: PSConfiguration.ps1
Get-DotfilesModuleNames | ForEach-Object {
    $m = $_
    Get-DotfilesProfiles | ForEach-Object {
        $p = $_
        foreach ($f in @("PSConfiguration.ps1")) {
            if (Test-Path -Path "$p/$m/$f") {
                Write-Debug "source $p/$m/$f"
                . "$p/$m/$f"
                return
            }
        }
    }
}