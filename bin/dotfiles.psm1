#!/usr/bin/env powershell

#$DebugPreference = "Continue"

function Get-DotfilesIsWindows() {
    if ($IsWindows) {
        return $true
    }
    if ($IsLinux -or $IsMacOS) {
        return $false
    }
    # old windows / powershell version
    return (Get-WmiObject Win32_OperatingSystem -ErrorAction Stop).Name.Contains("Windows")
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
        if (Get-DotfilesIsWindows) {
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

    # if link is a link or does not exists
    if (Test-Path $dst) {
        if(Compare-Object -ReferenceObject $(Get-Content $src) -DifferenceObject $(Get-Content $dst)) {
            Copy-Item $src $dst
            Write-Output "updated $dst ($src)"
        } else {
            Write-Output "skipped $dst"
        }
    } else {
        Copy-Item $src $dst
        Write-Output "create $dst"
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
    ForEach ($profile in Get-DotfilesProfiles) {
        if (Test-Path -Path "$profile/$src") {
            Set-DotfilesLink -src "$profile/$src" -dst $dst
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
            $m = $_
            Get-DotfilesProfiles | ForEach-Object {
                $p = $_
                if (Test-Path -Path "$p/$m/dotfiles-install.ps1") {
                    Write-Debug "Execute $p/$m/dotfiles-install.ps1"
                    Invoke-Expression "$p/$m/dotfiles-install.ps1"
                    return
                }
            }
        }
    } else {
        Get-DotfilesModules | ForEach-Object {
            $m = $_
            Get-DotfilesProfiles | ForEach-Object {
                $p = $_
                if (Test-Path -Path "$p/$m/dotfiles-install.ps1") {
                    Write-Debug "Execute $p/$m/dotfiles-install.ps1"
                    Invoke-Expression "$p/$m/dotfiles-install.ps1"
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
            $m = $_
            Get-DotfilesProfiles | ForEach-Object {
                $p = $_
                if (Test-Path -Path "$p/$m/dotfiles-configure.ps1") {
                    Write-Debug "Execute $p/$m/dotfiles-configure.ps1"
                    Invoke-Expression "$p/$m/dotfiles-configure.ps1"
                    return
                }
            }
        }
    } else {
        Get-DotfilesModules | ForEach-Object {
            $m = $_
            Get-DotfilesProfiles | ForEach-Object {
                $p = $_
                if (Test-Path -Path "$p/$m/dotfiles-configure.ps1") {
                    Write-Debug "Execute $p/$m/dotfiles-configure.ps1"
                    Invoke-Expression "$p/$m/dotfiles-configure.ps1"
                    return
                }
            }
        }
    }
}

function Update-DotfilesPowershellProfile {
    $new = $PROFILE.CurrentUserAllHosts + ".new"
    $old = $PROFILE.CurrentUserAllHosts

    New-Item -type directory -path $(Split-Path $PROFILE.CurrentUserAllHosts) -Force | Out-Null
    
    Write-Output '# Generated with Update-DotfilesProfile' > $new 

    Write-Output 'Import-Module "~/.dotfiles/bin/dotfiles.psm1" -ErrorAction Stop' >> $new

    Write-Output '# global files (All): PSConfiguration-global.ps1' >> $new 
    Get-DotfilesModules | ForEach-Object {
        $m = $_
        Get-DotfilesProfiles | Where-Object { $_.Name -eq "All" } | ForEach-Object {
            $p = $_
            if (Test-Path -Path "$p/$m/PSConfiguration-global.ps1") {
                Write-Output "# include $p/$m/PSConfiguration-global.ps1" >> $new 
                Get-Content "$p/$m/PSConfiguration.ps1" | Out-File -Append -FilePath $new 
            }
        }
    }

    Write-Output '# global files (OS): PSConfiguration-global.ps1' >> $new 
    Write-Output 'if (Get-DotfilesIsWindows) {' >> $new
    Get-DotfilesModules | ForEach-Object {
        $m = $_
        Get-DotfilesProfiles | Where-Object { $_.Name -eq "Windows" } | ForEach-Object {
            $p = $_
            if (Test-Path -Path "$p/$m/PSConfiguration-global.ps1") {
                Write-Output "# include $p/$m/PSConfiguration-global.ps1" >> $new 
                Get-Content "$p/$m/PSConfiguration.ps1" | Out-File -Append -FilePath $new 
            }
        }
    }
    Write-Output '}' >> $new 

    Write-Output 'if ($IsLinux) {' >> $new
    Get-DotfilesModules | ForEach-Object {
        $m = $_
        Get-DotfilesProfiles | Where-Object { $_.Name -eq "Linux" } | ForEach-Object {
            $p = $_
            if (Test-Path -Path "$p/$m/PSConfiguration-global.ps1") {
                Write-Output "# include $p/$momdule/PSConfiguration-global.ps1" >> $new 
                Get-Content "$p/$m/PSConfiguration.ps1" | Out-File -Append -FilePath $new 
            }
        }
    }
    Write-Output '}' >> $new 

    Write-Output 'if ($IsMacOS) {' >> $new
    Get-DotfilesModules | ForEach-Object {
        $m = $_
        Get-DotfilesProfiles | Where-Object { $_.Name -eq "Darwin" } | ForEach-Object {
            $p = $_
            if (Test-Path -Path "$p/$m/PSConfiguration-global.ps1") {
                Write-Output "# include $p/$m/PSConfiguration-global.ps1" >> $new 
                Get-Content "$p/$m/PSConfiguration.ps1" | Out-File -Append -FilePath $new 
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

function Update-DotfilesProfile {
    Update-DotfilesPowershellProfile
    Update-DotfilesModules
}

Export-ModuleMember -Function Set-DotfilesModuleLink

Export-ModuleMember -Function Get-DotfilesIsWindows
Export-ModuleMember -Function Get-DotfilesRoots
Export-ModuleMember -Function Get-DotfilesModules
Export-ModuleMember -Function Get-DotfilesProfiles
Export-ModuleMember -Function Install-DotfilesModules
Export-ModuleMember -Function Update-DotfilesProfile

# Export-ModuleMember -Function Update-DotfilesModules
# Export-ModuleMember -Function Update-DotfilesPowershellProfile