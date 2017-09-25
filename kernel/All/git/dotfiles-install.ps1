#!/usr/bin/env powershell

if (Get-Command choco -errorAction SilentlyContinue) {
    if (Get-Command git -errorAction SilentlyContinue) {
        choco upgrade git --confirm
    } else {
        choco install git --confirm
    }
}