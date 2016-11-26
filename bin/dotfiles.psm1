#!/usr/bin/env powershell

#$DebugPreference = "Continue"

function Get-DotfilesRoots () {
  <#
    .Synopsis
      Get all root dotfiles directories.
  #>
  $roots = @()
  Get-ChildItem -Path "~" -Filter ".dotfiles*" -Hidden | Sort-Object -Property Name -Descending | ForEach-Object {
    if ($_.Target) {
      $roots += Get-Item $_.Target
    } else {
      $roots += $_
    }
  }
  return $roots
}

function Get-DotfilesProfiles () {
  <#
    .Synopsis
      Get all dotfiles profiles directories.
  #>
  $profiles = @()
  foreach ($root in Get-DotfilesRoots) {
      if ($IsWindows) {
        $paths = @()
        $paths += Join-Path (Join-Path $root.FullName 'os') 'Windows'
        $paths += Join-Path (Join-Path $root.FullName 'os') 'All'
        $paths += Join-Path (Join-Path $root.FullName 'kernel') 'Windows'
        $paths += Join-Path (Join-Path $root.FullName 'kernel') 'All'
        foreach ($suffix in $paths) {
          $path = Join-Path $dotfiles_root $suffix
          if (Test-Path $path) {
            $profiles += Get-Item $path
          }
        }
      } elseif ($IsOSX) {
        $paths = @()
        $paths += Join-Path (Join-Path $root.FullName 'os') 'Darwin'
        $paths += Join-Path (Join-Path $root.FullName 'os') 'All'
        $paths += Join-Path (Join-Path $root.FullName 'kernel') 'Darwin'
        $paths += Join-Path (Join-Path $root.FullName 'kernel') 'All'
        foreach ($path in $paths) {
          if (Test-Path $path) {
            $profiles += Get-Item $path
          }
        }
      }
  }
  return $profiles     
}

function Set-DotfilesLink {
  <#
    .Synopsis
      Create a link and make a backup if necessary
  #>
  param(
    [Parameter(Mandatory=$true)]
    [string]$src,
    [Parameter(Mandatory=$true)]
    [string]$dst
  )

  # if link is a file or directory but not already link
  if (Test-Path $dst) {
    $isLink = (Get-Item $dst).Attributes.ToString() -match "ReparsePoint"
    $isFile = (Get-Item $dst).Attributes.ToString() -match "Normal"
    $isDirectory = (Get-Item $dst).Attributes.ToString() -match "Directory"
    
    Write-Debug "$dst link=$isLink file=$isFile directory=$isDirectory"
    if (!$isLink -and ($isFile -or $isDirectory)) {
      Remove-Item -Recurse -Force -Path "$dst.backup"
      Move-Item $dst "$dst.backup"
      Write-Output "moved $dst to $dst.backup" 
    }
  }

  # if link is a link or does not exists
  if (Test-Path $dst) {
    # if target is correct skip it
    $srctarget = (Get-Item $src).FullName
    $dsttarget = Get-Item $dst | Select-Object -ExpandProperty Target    
    if ($srctarget -eq $dsttarget) {
      Write-Output "skipped $src to $dsttarget"
    } else {
      New-Item -ItemType SymbolicLink -Path $dst -Value $src | Out-Null
      Write-Output "linked $src to $dst"
    }
  } else {
      New-Item -ItemType SymbolicLink -Path $dst -Value $src| Out-Null
      Write-Output "linked $src to $dst"
  }
}

function Set-DotfilesModuleLink {
  <#
    .Synopsis
      Create a link to the best maching profile.
  #>
  param(
    [Parameter(Mandatory=$true)]
    [string]$src,
    [Parameter(Mandatory=$true)]
    [string]$dst
  ) 
  Get-DotfilesProfiles | ForEach-Object {
    if (Test-Path -Path "$_/$src") {
      Set-DotfilesLink -src "$_/$src" -dst $dst
      break
    }
  }
}

Export-ModuleMember -Function Get-DotfilesRoots
Export-ModuleMember -Function Get-DotfilesProfiles
Export-ModuleMember -Function Set-DotfilesLink
Export-ModuleMember -Function Set-DotfilesModuleLink