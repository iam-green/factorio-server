@echo off

set GITHUB_REPO=iam-green/factorio-server
set GITHUB_BRANCH=main

if not exist "start.ps1" (
  powershell curl.exe -sfSLo .\start.ps1 ^
    "https://raw.githubusercontent.com/%GITHUB_REPO%/%GITHUB_BRANCH%/start.ps1"
)
attrib +h .\start.ps1
PowerShell.exe -ExecutionPolicy RemoteSigned -File .\start.ps1 %*
