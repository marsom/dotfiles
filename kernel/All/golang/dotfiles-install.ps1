#!/usr/bin/env powershell

if (Get-Command choco -errorAction SilentlyContinue) {
    choco install golang --version 1.7.6 --confirm
}