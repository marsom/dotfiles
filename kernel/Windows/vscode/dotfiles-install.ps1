#!/usr/bin/env powershell

if (Get-Command choco -errorAction SilentlyContinue) {
    if (Get-Command code -errorAction SilentlyContinue) {
        choco upgrade VisualStudioCode --confirm
    } else {
        choco install VisualStudioCode --confirm
    }
}