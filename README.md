# Kusi's dotfiles

Profile-based, os-aware dotfiles which allows to mix private and public dotfiles repositories.

## Installation

**Warning:** If you want to give these dotfiles a try, 
you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

Linux (optional):
* export http_proxy=http://proxy>:port
* export http_proxy=http://proxy>:port
* export http_proxy=localhost

Windows (optional)
* [Environment]::SetEnvironmentVariable("http_proxy", "http://proxy>:port", "User")
* [Environment]::SetEnvironmentVariable("https_proxy", "http://proxy>:port", "User")
* [Environment]::SetEnvironmentVariable("no_proxy", "localhost", "User")
* [Environment]::SetEnvironmentVariable("ChocolateyInstall", "c:\\path\\to\\chocolatey", "User")

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
```terminal
~/.dotfiles/bin/dofiles install
```

Configure the files, i.e. create links.
```terminal
~/.dotfiles/bin/dofiles configure
```

## Uninstall
Never tested :-)

## Inspired by...
- [https://github.com/holman/dotfiles](https://github.com/holman/dotfiles/) 
- [https://github.com/mathiasbynens/dotfiles]( https://github.com/mathiasbynens/dotfiles)
