#!/bin/bash
set -e  # Exit immediately on error

# Default directories and repository settings
DATA_DIRECTORY="."                           # Default data directory is the current directory.
LIBRARY_DIRECTORY="$HOME/.iam-green"         # Default library directory.
GITHUB_REPO="iam-green/factorio-server"  # GitHub repository.
GITHUB_BRANCH="main"                         # GitHub branch to use for updates.

# Add your desired environment variables here

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -h, --help                                   Display help and exit."
  echo "  -v, --version <stable|experimental|version>  Specify the version of Factorio to install."
  echo "  -d, -dd, --data-directory <directory>        Choose the data directory."
  echo "  -ld, --library-directory <directory>         Choose the library directory."
  echo "  -u, --update                                 Update code to the latest version."
}

has_argument() {
  [[ ("$1" == *=* && -n "${1#*=}") || ( -n "$2" && "$2" != -* ) ]]
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

handle_argument() {
  while [ $# -gt 0 ]; do
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      -d|-dd|--data-directory)
        if ! has_argument "$@"; then
          echo "The directory is not specified correctly." >&2
          usage
          exit 1
        fi
        DATA_DIRECTORY=$(extract_argument "$@")
        shift
        ;;
      -ld|--library-directory)
        if ! has_argument "$@"; then
          echo "The directory is not specified correctly." >&2
          usage
          exit 1
        fi
        LIBRARY_DIRECTORY=$(extract_argument "$@")
        shift
        ;;
      -u|--update)
        # Update the current script using curl from the GitHub repository.
        curl -s -o "./start.sh" -L "https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/start.sh"
        chmod +x "./start.sh"
        echo "Code updated. Please re-run the code."
        exit 0
        ;;
      # Add your desired parameters here
      *)
        echo "Invalid option: $1" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done
}

set_timezone() {
  if [ -n "$TZ" ]; then
    ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
  fi
}

directory_setting() {
  if [ ! -d "$DATA_DIRECTORY" ]; then
    mkdir -p "$DATA_DIRECTORY"
  fi
  if [ ! -d "$LIBRARY_DIRECTORY" ]; then
    mkdir -p "$LIBRARY_DIRECTORY"
  fi

  # Resolve absolute paths
  DATA_DIRECTORY=$(realpath "$DATA_DIRECTORY")
  LIBRARY_DIRECTORY=$(realpath "$LIBRARY_DIRECTORY")
}

create_group_user() {
  if [ -z "$UID" ] || [ -z "$GID" ]; then
    USER=$( [ "$(uname)" = "Darwin" ] && id -un || getent passwd "$(id -u)" | cut -d: -f1 )
    return 0
  fi
  if id "$UID" >/dev/null 2>&1 && getent group "$GID" >/dev/null 2>&1; then
    USER=$( [ "$(uname)" = "Darwin" ] && id -un "$UID" || getent passwd "$UID" | cut -d: -f1 )
    return 0
  fi
  if ! getent group "$GID" >/dev/null 2>&1; then
    groupadd -g "$GID" user
  fi
  if ! id "$UID" &>/dev/null; then
    useradd -u "$UID" -g "$GID" -m user
  fi
  USER=$( [ "$(uname)" = "Darwin" ] && id -un "$UID" || getent passwd "$UID" | cut -d: -f1 )
}

get_os() {
  if [ $(uname) == "Darwin" ]; then
    echo "macos"
  else
    echo "linux"
  fi
}

get_arch() {
  case $(uname -m) in
    "x86_64")
      echo "amd64"
      ;;
    "arm64" | "aarch64")
      echo "arm64"
      ;;
  esac
}

handle_argument "$@"
set_timezone
directory_setting
create_group_user

# Add your desired functions or code from here
