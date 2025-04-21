# Add your desired parameters here
[CmdletBinding()]
param(
  [Parameter(Mandatory=$false, HelpMessage="Display help and exit.")]
  [Alias("h", "help")]
  [switch]$ShowHelp,

  [Parameter(Mandatory=$false, HelpMessage="Choose the data directory.")]
  [Alias("d", "dd", "data-directory")]
  [string]$DataDirectory = ".",

  [Parameter(Mandatory=$false, HelpMessage="Choose the library directory.")]
  [Alias("ld", "library-directory")]
  [string]$LibraryDirectory,

  [Parameter(Mandatory=$false, HelpMessage="Update code to the latest version.")]
  [Alias("u", "update")]
  [switch]$CodeUpdate
)

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

foreach ($paramName in $MyInvocation.MyCommand.Parameters.Keys) {
  Set-Variable -Name $paramName -Value (Get-Variable -Name $paramName -ValueOnly) -Scope Global
}

if (-not $global:LibraryDirectory) {
  $global:LibraryDirectory = (Join-Path ([System.Environment]::GetFolderPath('UserProfile')) '.iam-green')
}

# Default repository settings
$global:GITHUB_REPO = "iam-green/factorio-server"  # GitHub repository.
$global:GITHUB_BRANCH = "main"                     # GitHub branch to use for update.

function Show-Usage {
  Write-Host "Usage: ./start.ps1 [OPTIONS]"
  Write-Host "Options:"
  Write-Host "  -h, -help                             Display help and exit."
  Write-Host "  -d, -dd, -data-directory <directory>  Choose the data directory."
  Write-Host "  -ld, -library-directory <directory>   Choose the library directory."
  Write-Host "  -u, -update                           Update code to the latest version."
}

if ($global:ShowHelp) {
  Show-Usage
  exit 0
}

# Execute update
if ($global:CodeUpdate) {
  $url = "https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/start.ps1"
  try {
    Invoke-WebRequest -Uri $url -OutFile "./start.ps1" -ErrorAction Stop
    Write-Host "Code updated. Please re-run the code."
    exit 0
  } catch {
    Write-Error "Update failed: $_"
    exit 1
  }
}

function Get-SystemInfo {
  $osInfo = @{}
  if ($IsWindows) {
    $osInfo.OS = "windows"
    $osInfo.Architecture = if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") { "amd64" } else { "arm64" }
  }
  elseif ($IsLinux) {
    $osInfo.OS = "linux"
    $osInfo.Architecture = if ((uname -m) -eq "x86_64") { "amd64" } else { "arm64" }
  }
  elseif ($IsMacOS) {
    $osInfo.OS = "macos"
    $osInfo.Architecture = if ((uname -m) -eq "x86_64") { "amd64" } else { "arm64" }
  }
  return $osInfo
}

function Directory-Setting {
  if (-not (Test-Path $global:DataDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $global:DataDirectory -Force | Out-Null
  }
  if (-not (Test-Path $global:LibraryDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $global:LibraryDirectory -Force | Out-Null
  }
  $global:DataDirectory = (Resolve-Path $global:DataDirectory).Path
  $global:LibraryDirectory = (Resolve-Path $global:LibraryDirectory).Path
}

Directory-Setting

# Add your desired functions or code from here
