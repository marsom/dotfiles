# My dotfiles & software manager

Profile-based, os-aware dotfiles which allows to mix private and public dotfiles repositories.

## Installation

**Warning:** If you want to give these dotfiles a try, 
you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

Linux/macOS (optional):

```bash
export http_proxy=http://proxy:port
export http_proxy=http://proxy:port
export http_proxy=localhost
```

Windows (optional)

```powershell
[Environment]::SetEnvironmentVariable("http_proxy", "http://proxy:port", "User")
[Environment]::SetEnvironmentVariable("https_proxy", "http://proxy:port", "User")
[Environment]::SetEnvironmentVariable("no_proxy", "localhost", "User")
[Environment]::SetEnvironmentVariable("ChocolateyInstall", "c:\\path\\to\\chocolatey", "User")
[Environment]::SetEnvironmentVariable("ChocolateyToolsLocation", "c:\\path\\to\\tools", "User")
```

If you do not have a git installation, please install [brew](https://brew.sh/), [linuxbrew](http://linuxbrew.sh/), [Chocolatey](https://chocolatey.org/) and install git.

### git based install

Checkout your/my public dotfiles repository.

```terminal
git clone git://github.com/marsom/dotfiles ~/.dotfiles
```

Checkout your second dotfiles repository, i.e. your private repository.

```terminal
git clone git://github.com/marsom/dotfiles ~/.dotfiles.0
```

## Usage

Install the required binaries, i.e. golang, homebrew.

Linux/macOS

```bash
~/.dotfiles/bin/dofiles install
```

Windwos

```powershell
Import-Module .\.dotfiles\bin\dotfiles.psm1
Install-DotfilesModules
```

Configure the files, i.e. create links.

Linux/macOS

```bash
~/.dotfiles/bin/dofiles update-profile
```

Windwos

```powershell
Import-Module .\.dotfiles\bin\dotfiles.psm1
Update-DotfilesProfile
```

## Uninstall

Never tested :-)

## Inspired by

- [https://github.com/holman/dotfiles](https://github.com/holman/dotfiles/) 
- [https://github.com/mathiasbynens/dotfiles]( https://github.com/mathiasbynens/dotfiles)
