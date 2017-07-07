#!/usr/bin/env powershell

#Requires -Version 3

param (
    [switch]$install = $false,
    [switch]$configure = $false,
    [switch]$listroots = $false,
    [switch]$listmodules = $false,
    [switch]$listprofiles = $false,
    [switch]$help = $false,
    [string]$module = $null
)

#$DebugPreference = "Continue"

Import-Module "$PSScriptRoot/dotfiles.psm1" -ErrorAction Stop

function ExitWithCode { 
    <#
    .Synopsis
      Exit with given exit code.
  #>
    param (
        $exitcode
    )
    $host.SetShouldExit($exitcode)
    #exit
}

function Get-DotfilesModules {
    <#
    .Synopsis
      Get all available modules.
  #>
    $modules = @()
    if ($module) {
        $modules += $module 
    }
    else {
        foreach ($root in Get-DotfilesProfiles) {
            Get-ChildItem -Path $root.FullName -Directory | ForEach-Object {$modules += $_.Name} 
        }
    }
    return $modules | Select-Object -Unique
}

function Install-DotfilesModules {
    <#
    .Synopsis
     Install requried software.
  #>
    Get-DotfilesModules | ForEach-Object {
        $module = $_
        Get-DotfilesProfiles | ForEach-Object {
            $profile = $_
            if (Test-Path -Path "$profile/$module/dotfiles-install.ps1") {
                Write-Debug "Execute $profile/$module/dotfiles-install.ps1"
                Invoke-Expression "$profile/$module/dotfiles-install.ps1"
                break
            }
        }
    }
}

function Update-DotfilesModules {
    <#
    .Synopsis
      Update/Configure modules.
  #>
    Get-DotfilesModules | ForEach-Object {
        $module = $_
        Get-DotfilesProfiles | ForEach-Object {
            $profile = $_
            if (Test-Path -Path "$profile/$module/dotfiles-configure.ps1") {
                Write-Debug "Execute $profile/$module/dotfiles-configure.ps1"
                Invoke-Expression "$profile/$module/dotfiles-configure.ps1"
                break
            }
        }
    }
}

if ($help) {
    Get-Help $MyInvocation.MyCommand.Path
    ExitWithCode 0
}

if ($listroots) {
    Get-DotfilesRoots | Select-Object FullName | Format-Table -HideTableHeaders
    ExitWithCode 0
}

if ($listprofiles) {
    Get-DotfilesProfiles | Select-Object FullName | Format-Table -HideTableHeaders
    ExitWithCode 0
}

if ($listmodules) {
    Get-DotfilesModules
    ExitWithCode 0
}

# mklink requires admin rights on vista, elevate permissions.
if (IsWindows -and -not $IsCoreCLR) {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        if ((Get-WmiObject Win32_OperatingSystem | select BuildNumber).BuildNumber -ge 6000) {
            Write-Verbose "Found UAC-enabled system. Elevating ..."
            $CommandLine = $MyInvocation.Line.Replace($MyInvocation.InvocationName, $MyInvocation.MyCommand.Definition)
            Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-noexit $CommandLine"
        }
        else {
            Write-Verbose "System does not support UAC"
            Write-Warning "This script requires administrative privileges. Elevation not possible. Please re-run with administrative account."
            ExitWithCode 5
        }
        break
    }
}

if ($install) {
    Install-DotfilesModules
    #ExitWithCode 0
}

if ($configure) {
    Update-DotfilesModules
    #ExitWithCode 0
}