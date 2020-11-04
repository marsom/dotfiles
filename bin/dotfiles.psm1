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
    if ($IsLinux -or $IsMacOS) {
        return $false
    }
    return false
}

function Get-SymLinkTarget {
    <#
    .Synopsis
      get link target
  #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$link
    )
    if ($IsCoreCLR) {
        Get-Item $link | Select-Object -ExpandProperty Target
    }
    elseif ($IsWindows) {
        $resolvedLink = Force-Resolve-Path -FileName $link
        $basePath = Split-Path $resolvedLink
        $folder = Split-Path -leaf $resolvedLink
        $dir = cmd /c dir /a:l $basePath | Select-String $folder
        $dir = $dir -join ' '
        $regx = $folder + '\ *\[(.*?)\]'
        $Matches = $null
        $found = $dir -match $regx
        if ($found) {
            if ($Matches[1]) {
                return $Matches[1]
            }
        }
        return '' 
    }
}

function New-SymLink {
    <#
    .Synopsis
      Create a link.
  #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$link,
        [Parameter(Mandatory = $true)]
        [string]$target
    )
    if ($IsCoreCLR) {
        New-Item -ItemType SymbolicLink -Path $link -Value $target
    }
    elseif (IsWindows) {
        $resolvedLink = Force-Resolve-Path -FileName $link
        $resolvedTarget = Force-Resolve-Path -FileName $target
    
        if (Test-Path -PathType Container $target) {
            $command = "cmd /c mklink /d"
        }
        else {
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
        }
        else {
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
            $paths += Join-Path (Join-Path $root.FullName 'os') 'All'
            $paths += Join-Path (Join-Path $root.FullName 'kernel') 'Windows'
            $paths += Join-Path (Join-Path $root.FullName 'kernel') 'All'
            foreach ($path in $paths) {
                if (Test-Path $path) {
                    $profiles += Get-Item $path
                }
            }
        }
        elseif ($IsMacOS) {
            $paths = @()
            $paths += Join-Path (Join-Path $root.FullName 'os') 'All'
            $paths += Join-Path (Join-Path $root.FullName 'kernel') 'Darwin'
            $paths += Join-Path (Join-Path $root.FullName 'kernel') 'All'
            foreach ($path in $paths) {
                if (Test-Path $path) {
                    $profiles += Get-Item $path
                }
            }
        }
        elseif ($IsLinux) {
            $paths = @()
            $paths += Join-Path (Join-Path $root.FullName 'os') 'All'
            $paths += Join-Path (Join-Path $root.FullName 'kernel') 'Linux'
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

function Get-DotfilesModuleNames {
    <#
    .Synopsis
      Get all available module names
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

function Set-DotfilesCreateProfile {
    <#
    .Synopsis
      Create the concatenated profile
    #>
    Write-Output "Create the concatenated profile" 

    # source global files: PSConfiguration-global.ps1
    Get-DotfilesModuleNames | ForEach-Object { 
        $m = $_
        Get-DotfilesProfiles | ForEach-Object {
            $p = $_
            foreach ($f in @("PSConfiguration-global.ps1")) {
                Write-Debug "test $p/$m/$f"
                if (Test-Path -Path "$p/$m/$f") {
                    Write-Output "source $p/$m/$f"
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
                Write-Debug "test $p/$m/$f"
                if (Test-Path -Path "$p/$m/$f") {
                    Write-Output "source $p/$m/$f"
                    Get-Content -Path $p/$m/$f
                    continue
                }
            }
        }
    }
}

function Set-DotfilesLink {
    <#
    .Synopsis
      Create a link and make a backup if necessary
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$src,
        [Parameter(Mandatory = $true)]
        [string]$dst
    )

    # if link is a file or directory but not already link
    if (Test-Path $dst) {
        $dstFile = Get-Item $dst -Force

        $isLink = [bool]($dstFile.Attributes -band [IO.FileAttributes]::ReparsePoint)
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
        $dsttarget = Get-SymLinkTarget -link $dst
        Write-Debug "src target $srctarget"
        Write-Debug "dst target $dsttarget"
        if ($srctarget -eq $dsttarget) {
            Write-Output "skipped $src to $dsttarget"
        }
        else {
            New-SymLink -link $dst -target $src | Out-Null
            Write-Output "linked $src to $dst"
        }
    }
    else {
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
        [Parameter(Mandatory = $true)]
        [string]$src,
        [Parameter(Mandatory = $true)]
        [string]$dst
    ) 
    Get-DotfilesProfiles | ForEach-Object {
        if (Test-Path -Path "$_/$src") {
            Set-DotfilesLink -src "$_/$src" -dst $dst
            return
        }
    }
}

function Get-DotfilesModules {
    <#
    .Synopsis
      Get all available modules.
    #>
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$Module
    )
    $modules = @()
    if ($Module.Length -gt 0) {
        $Module | ForEach-Object {
            $modules += $_
        } 
    } else {
        foreach ($root in Get-DotfilesProfiles) {
            Get-ChildItem -Path $root.FullName -Directory | ForEach-Object {
                $modules += $_.Name
            } 
        }
    }
    return $modules | Select-Object -Unique
}

function Install-DotfilesModules {
    <#
    .Synopsis
      Install requried software.
    #>
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$Module
    )
    if ($Module.Length -gt 0) {
        Get-DotfilesModules -Module $Module | ForEach-Object {
            $module = $_
            Get-DotfilesProfiles | ForEach-Object {
                $profile = $_
                if (Test-Path -Path "$profile/$module/dotfiles-install.ps1") {
                    Write-Debug "Execute $profile/$module/dotfiles-install.ps1"
                    Invoke-Expression "$profile/$module/dotfiles-install.ps1"
                    return
                }
            }
        }
    } else {
        Get-DotfilesModules | ForEach-Object {
            $module = $_
            Get-DotfilesProfiles | ForEach-Object {
                $profile = $_
                if (Test-Path -Path "$profile/$module/dotfiles-install.ps1") {
                    Write-Debug "Execute $profile/$module/dotfiles-install.ps1"
                    Invoke-Expression "$profile/$module/dotfiles-install.ps1"
                    return
                }
            }
        }
    }

}

function Update-DotfilesModules {
    <#
    .Synopsis
      Update/Configure modules.
    #>
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$Module
    )
    if ($Module.Length -gt 0) {
        Get-DotfilesModules -Module $Module | ForEach-Object {
            $module = $_
            Get-DotfilesProfiles | ForEach-Object {
                $profile = $_
                if (Test-Path -Path "$profile/$module/dotfiles-configure.ps1") {
                    Write-Debug "Execute $profile/$module/dotfiles-configure.ps1"
                    Invoke-Expression "$profile/$module/dotfiles-configure.ps1"
                    return
                }
            }
        }
    } else {
        Get-DotfilesModules | ForEach-Object {
            $module = $_
            Get-DotfilesProfiles | ForEach-Object {
                $profile = $_
                if (Test-Path -Path "$profile/$module/dotfiles-configure.ps1") {
                    Write-Debug "Execute $profile/$module/dotfiles-configure.ps1"
                    Invoke-Expression "$profile/$module/dotfiles-configure.ps1"
                    return
                }
            }
        }
    }
}


function Update-DotfilesProfile {
    $new = $PROFILE.CurrentUserAllHosts + ".new"
    $old = $PROFILE.CurrentUserAllHosts

    New-Item -type directory -path $(Split-Path $PROFILE.CurrentUserAllHosts) -Force | Out-Null
    
    Write-Output '# Generated with Update-DotfilesProfile' > $new 

    Write-Output 'Import-Module "~/.dotfiles/bin/dotfiles.psm1" -ErrorAction Stop' >> $new

    Write-Output '# global files (All): PSConfiguration-global.ps1' >> $new 
    Get-DotfilesModules | ForEach-Object {
        $module = $_
        Get-DotfilesProfiles | Where-Object { $_.Name -eq "All" } | ForEach-Object {
            $profile = $_
            if (Test-Path -Path "$profile/$module/PSConfiguration-global.ps1") {
                Write-Output "# include $profile/$module/PSConfiguration-global.ps1" >> $new 
                Get-Content "$profile/$module/PSConfiguration.ps1" | Out-File -Append -FilePath $new 
            }
        }
    }

    Write-Output '# global files (OS): PSConfiguration-global.ps1' >> $new 
    Write-Output 'if ($IsWindows) {' >> $new
    Get-DotfilesModules | ForEach-Object {
        $module = $_
        Get-DotfilesProfiles | Where-Object { $_.Name -eq "Windows" } | ForEach-Object {
            $profile = $_
            if (Test-Path -Path "$profile/$module/PSConfiguration-global.ps1") {
                Write-Output "# include $profile/$module/PSConfiguration-global.ps1" >> $new 
                Get-Content "$profile/$module/PSConfiguration.ps1" | Out-File -Append -FilePath $new 
            }
        }
    }
    Write-Output '}' >> $new 

    Write-Output 'if ($IsLinux) {' >> $new
    Get-DotfilesModules | ForEach-Object {
        $module = $_
        Get-DotfilesProfiles | Where-Object { $_.Name -eq "Linux" } | ForEach-Object {
            $profile = $_
            if (Test-Path -Path "$profile/$module/PSConfiguration-global.ps1") {
                Write-Output "# include $profile/$module/PSConfiguration-global.ps1" >> $new 
                Get-Content "$profile/$module/PSConfiguration.ps1" | Out-File -Append -FilePath $new 
            }
        }
    }
    Write-Output '}' >> $new 

    Write-Output 'if ($IsMacOS) {' >> $new
    Get-DotfilesModules | ForEach-Object {
        $module = $_
        Get-DotfilesProfiles | Where-Object { $_.Name -eq "Darwin" } | ForEach-Object {
            $profile = $_
            if (Test-Path -Path "$profile/$module/PSConfiguration-global.ps1") {
                Write-Output "# include $profile/$module/PSConfiguration-global.ps1" >> $new 
                Get-Content "$profile/$module/PSConfiguration.ps1" | Out-File -Append -FilePath $new 
            }
        }
    }
    Write-Output '}' >> $new 

    Write-Output '# source best maching files: PSConfiguration.ps1' >> $new
    ForEach ($module in Get-DotfilesModules) {
        ForEach ($profile in Get-DotfilesProfiles) {
            if (Test-Path -Path "$profile/$module/PSConfiguration.ps1") {
                Write-Output "# include $profile/$module/PSConfiguration.ps1" >> $new 
                Get-Content "$profile/$module/PSConfiguration.ps1" | Out-File -Append -FilePath $new
                break
            }
        }
    }

    if (Test-Path $old) {
        if(Compare-Object -ReferenceObject $(Get-Content $new) -DifferenceObject $(Get-Content $old)) {
            Copy-Item $new $old
            Write-Output "updated $old"
        } else {
            Write-Output "skipped $old"
        }
    } else {
        Copy-Item $new $old
        Write-Output "updated $old"
    }
}




Export-ModuleMember -Function IsWindows
Export-ModuleMember -Function Get-DotfilesRoots
Export-ModuleMember -Function Get-DotfilesProfiles
Export-ModuleMember -Function Get-DotfilesModuleNames
Export-ModuleMember -Function Set-DotfilesLink
Export-ModuleMember -Function Set-DotfilesModuleLink
Export-ModuleMember -Function Set-DotfilesCreateProfile

Export-ModuleMember -Function Get-DotfilesModules
Export-ModuleMember -Function Install-DotfilesModules
Export-ModuleMember -Function Update-DotfilesModules
Export-ModuleMember -Function Update-DotfilesProfile

