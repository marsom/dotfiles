#!/usr/bin/env powershell

#$DebugPreference = "Continue"

function Force-Resolve-Path {
  <#
  .SYNOPSIS
    Calls Resolve-Path but works for files that don't exist.
  .REMARKS
    From http://devhawk.net/2010/01/21/fixing-powershells-busted-resolve-path-cmdlet/
  #>
  param (
    [string] $FileName
  )
  $FileName = Resolve-Path $FileName -ErrorAction SilentlyContinue -ErrorVariable _frperror
  if (-not($FileName)) {
    $FileName = $_frperror[0].TargetObject
  }
  return $FileName
}

function IsWindows() {
  if ($IsWindows) {
    return $true
  }
  if ($IsLinux -or $IsOSX) {
    return $false
  }
  # old windows / powershell version
  return (Get-WmiObject Win32_OperatingSystem -ErrorAction Stop).Name.Contains("Windows")
}

function New-SymLink {
  <#
    .Synopsis
      Create a link.
  #>
  param(
    [Parameter(Mandatory=$true)]
    [string]$link,
    [Parameter(Mandatory=$true)]
    [string]$target
  )
  if ($IsCoreCLR) {
    New-Item -ItemType SymbolicLink -Path $link -Value $target
  } elseif (IsWindows) {
    $resolvedLink = Force-Resolve-Path -FileName $link
    $resolvedTarget = Force-Resolve-Path -FileName $target
    
    if (Test-Path -PathType Container $target) {
      $command = "cmd /c mklink /d"
    } else {
      $command = "cmd /c mklink"
    }
    Write-Debug "create legacy cmd='$command' link=$resolvedLink target=$resolvedTarget"
    Invoke-Expression "$command $resolvedLink $resolvedTarget"
  }
}

function Get-DotfilesRoots () {
  <#
    .Synopsis
      Get all root dotfiles directories.
  #>
  $roots = @()
  Get-ChildItem -Path "~" -Filter ".dotfiles*" -Force | Sort-Object -Property Name -Descending | ForEach-Object {
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
      if (IsWindows) {
        $paths = @()
        $paths += Join-Path (Join-Path $root.FullName 'os') 'Windows'
        $paths += Join-Path (Join-Path $root.FullName 'os') 'All'
        $paths += Join-Path (Join-Path $root.FullName 'kernel') 'Windows'
        $paths += Join-Path (Join-Path $root.FullName 'kernel') 'All'
        foreach ($path in $paths) {
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
    $dstFile = Get-Item $dst -Force

    $istLink = [bool]($dstFile.Attributes -band [IO.FileAttributes]::ReparsePoint)
    $isFile = [bool]($dstFile.Attributes -band [IO.FileAttributes]::Normal)
    $isDirectory = [bool]($dstFile.Attributes -band [IO.FileAttributes]::Directory)
    $isArchive = [bool]($dstFile.Attributes -band [IO.FileAttributes]::Archive)

    Write-Debug "$dst link=$isLink file=$isFile directory=$isDirectory archive=$isArchive"
    if (!$isLink -and ($isFile -or $isDirectory -or $isArchive)) {
      Remove-Item -Recurse -Force -Path "$dst.backup" -ErrorAction SilentlyContinue
      Move-Item $dst "$dst.backup"
      Write-Output "moved $dst to $dst.backup" 
    }
  }

  # if link is a link or does not exists
  if (Test-Path $dst) {
    # if target is correct skip it
    $srctarget = (Get-Item $src).FullName
    $dsttarget = Get-Item $dst | Select-Object -ExpandProperty Target -ErrorAction SilentlyContinue
    Write-Debug "src target $srctarget"
    Write-Debug "dst target $dsttarget"
    if ($srctarget -eq $dsttarget) {
      Write-Output "skipped $src to $dsttarget"
    } else {
      New-SymLink -link $dst -target $src | Out-Null
      Write-Output "linked $src to $dst"
    }
  } else {
      New-SymLink -link $dst -target $src | Out-Null
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