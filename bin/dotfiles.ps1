#!/usr/bin/env powershell

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
  exit
}

function Get-DotfilesModules {
  <#
    .Synopsis
      Get all available modules.
  #>
  $modules = @()
  if ($module) {
    $modules += $module 
  } else {
    foreach ($dotfiles_root in Get-DotfilesProfiles) {
      Get-ChildItem $dotfiles_root.FullName -Depth 1 -Directory | ForEach-Object {$modules += $_.Name} 
    }
  }
  return $modules | Select -Unique
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

if ($install) {
  Install-DotfilesModules
  ExitWithCode 0
}

if ($configure) {
  Update-DotfilesModules
  ExitWithCode 0
}