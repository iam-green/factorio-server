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
  [string]$LibraryDirectory = "$([System.Environment]::GetFolderPath('UserProfile'))/.iam-green",

  [Parameter(Mandatory=$false, HelpMessage="Update code to the latest version.")]
  [Alias("u", "update")]
  [switch]$CodeUpdate
)

# Default repository settings
$GITHUB_REPO = "iam-green/auto-utils-template"  # GitHub repository.
$GITHUB_BRANCH = "main"                         # GitHub branch to use for update.

# Add your desired environment variables here

function Show-Usage {
  Write-Host "Usage: ./start.ps1 [OPTIONS]"
  Write-Host "Options:"
  Write-Host "  -h, -help                             Display help and exit."
  Write-Host "  -d, -dd, -data-directory <directory>  Choose the data directory."
  Write-Host "  -ld, -library-directory <directory>   Choose the library directory."
  Write-Host "  -u, -update                           Update code to the latest version."
}

if ($ShowHelp) {
  Show-Usage
  exit 0
}

# Execute update
if ($CodeUpdate) {
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

function Directory-Setting {
  if (-not (Test-Path $DataDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $DataDirectory -Force | Out-Null
  }
  if (-not (Test-Path $LibraryDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $LibraryDirectory -Force | Out-Null
  }
  # Resolve absolute paths
  $resolvedData = (Resolve-Path $DataDirectory).Path
  $resolvedLibrary = (Resolve-Path $LibraryDirectory).Path
  return @($resolvedData, $resolvedLibrary)
}

# Set directory paths
$resolvedPaths = Directory-Setting
$DataDirectory = $resolvedPaths[0]
$LibraryDirectory = $resolvedPaths[1]

# Add your desired functions or code from here
