#!/usr/bin/env powershell

#Requires -Version 3

param (
    [switch]$install = $false,
    [switch]$configure = $false,
    [switch]$profile = $false,
    [switch]$listroots = $false,
    [switch]$listmodules = $false,
    [switch]$listprofiles = $false,
    [switch]$help = $false,
    [string]$module = $null
)

#$DebugPreference = "Continue"

Import-Module "$PSScriptRoot/dotfiles.psm1" -ErrorAction Stop

if ($help) {
    Get-Help $MyInvocation.MyCommand.Path
    break endofscript
}

if ($listroots) {
    Get-DotfilesRoots | Select-Object FullName | Format-Table -HideTableHeaders
    break endofscript
}

if ($listprofiles) {
    Get-DotfilesProfiles | Select-Object FullName | Format-Table -HideTableHeaders
    break endofscript
}

if ($listmodules) {
    Get-DotfilesModules
    break endofscript
}

# creating symlinks on windows requires admin rights
if (-not ($IsLinux -or $IsOSX) -and ($IsWindows) -and -not $IsCoreCLR) {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { 
        Write-Warning "Found UAC-enabled system. Elevating ..."
        $CommandLine = $MyInvocation.Line.Replace($MyInvocation.InvocationName, $MyInvocation.MyCommand.Definition)
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-NoExit $CommandLine"
        exit
    }
}

if ($install) {
    Install-DotfilesModules
    $host.SetShouldExit($exitcode)
}

if ($configure) {
    Update-DotfilesModules
    $host.SetShouldExit($exitcode)
}

if ($profile) {
    Update-DotfilesProfile
    $host.SetShouldExit($exitcode)
}