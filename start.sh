#!/bin/bash
set -e  # Exit immediately on error

# Default directories and repository settings
DATA_DIRECTORY="./data"                 # Default data directory is the current directory.
LIBRARY_DIRECTORY="$HOME/.iam-green"    # Default library directory.
GITHUB_REPO="iam-green/factorio-server" # GitHub repository.
GITHUB_BRANCH="main"                    # GitHub branch to use for updates.

# Add your desired environment variables here
VERSION="stable"
MAP_NAME="factorio"
PORT=34197
WHITELIST_ENABLE=false
FACTORIO_DIRECTORY="./factorio"
FACTORIO_CLI=
FACTORIO_USERNAME=
FACTORIO_TOKEN=
SPACE_AGE_ENABLE=false
ELEVATED_RAILS_ENABLE=false
QUALITY_ENABLE=false

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -h, --help                                   Display help and exit."
  echo "  -v, --version <stable|experimental|version>  Specify the version of Factorio to install."
  echo "  -m, --map-name <name>                        Specify the map name."
  echo "  -p, --port <port>                            Specify the port number."
  echo "  -w, --whitelist                              Enable whitelist."
  echo "  -sa, --space-age                             Enable Space Age DLC."
  echo "  -er, --elevated-rails                        Enable Elevated Rails DLC."
  echo "  -q, --quality                                Enable Quality DLC."
  echo "  -u, --username <username>                    Specify the Factorio account username."
  echo "  -t, --token <token>                          Specify the Factorio account token."
  echo "  -d, -dd, --data-directory <directory>        Choose the data directory."
  echo "  -ld, --library-directory <directory>         Choose the library directory."
  echo "  -fd, --factorio-directory <directory>        Choose the Factorio directory."
  echo "  -u, --update                                 Update code to the latest version."
}

has_argument() {
  [[ ("$1" == *=* && -n "${1#*=}") || (-n "$2" && "$2" != -*) ]]
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
      -v|--version)
        if ! has_argument "$@"; then
          echo "The version is not specified correctly." >&2
          usage
          exit 1
        fi
        VERSION=$(extract_argument "$@")
        shift
        ;;
      -p|--port)
        if ! has_argument "$@"; then
          echo "The port is not specified correctly." >&2
          usage
          exit 1
        fi
        PORT=$(extract_argument "$@")
        shift
        ;;
      -w|--whitelist)
        WHITELIST_ENABLE=true
        ;;
      -m|--map-name)
        if ! has_argument "$@"; then
          echo "The map name is not specified correctly." >&2
          usage
          exit 1
        fi
        MAP_NAME=$(extract_argument "$@")
        shift
        ;;
      -sa|--space-age)
        SPACE_AGE_ENABLE=true
        ;;
      -er|--elevated-rails)
        ELEVATED_RAILS_ENABLE=true
        ;;
      -q|--quality)
        QUALITY_ENABLE=true
        ;;
      -u|--username)
        if ! has_argument "$@"; then
          echo "The username is not specified correctly." >&2
          usage
          exit 1
        fi
        FACTORIO_USERNAME=$(extract_argument "$@")
        shift
        ;;
      -t|--token)
        if ! has_argument "$@"; then
          echo "The token is not specified correctly." >&2
          usage
          exit 1
        fi
        FACTORIO_TOKEN=$(extract_argument "$@")
        shift
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
      -fd|--factorio-directory)
        if ! has_argument "$@"; then
          echo "The directory is not specified correctly." >&2
          usage
          exit 1
        fi
        FACTORIO_DIRECTORY=$(extract_argument "$@")
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
  if [ ! -d "$FACTORIO_DIRECTORY" ]; then
    mkdir -p "$FACTORIO_DIRECTORY"
  fi
  if [ ! -d "$LIBRARY_DIRECTORY" ]; then
    mkdir -p "$LIBRARY_DIRECTORY"
  fi

  # Resolve absolute paths
  DATA_DIRECTORY=$(realpath "$DATA_DIRECTORY")
  FACTORIO_DIRECTORY=$(realpath "$FACTORIO_DIRECTORY")
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
  if [ "$(uname)" == "Darwin" ]; then
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

install_jq() {
  if [ ! -e "$LIBRARY_DIRECTORY/jq" ]; then
    curl -s -o "$LIBRARY_DIRECTORY/jq" -L "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-$(get_os)-$(get_arch)"
    chmod +x "$LIBRARY_DIRECTORY/jq"
  fi
}

get_factorio_version() {
  local data
  data=$(curl -s https://factorio.com/api/latest-releases)
  case "$VERSION" in
    stable)
      VERSION=$(echo "$data" | "$LIBRARY_DIRECTORY/jq" -r '.stable.alpha')
      ;;
    experimental)
      VERSION=$(echo "$data" | "$LIBRARY_DIRECTORY/jq" -r '.experimental.alpha')
      ;;
  esac
}

check_factorio_version_exist() {
  local url="https://factorio.com/get-download/$VERSION/headless/linux64"
  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [ "$http_code" -eq 404 ]; then
    echo "Factorio Version $VERSION does not exist." >&2
    exit 1
  fi
}

check_arch() {
  local arch
  local os
  arch=$(get_arch)
  os=$(get_os)
  if [[ -z "$arch" || ( "$os" == "linux" && "$arch" == "arm64" ) ]]; then
    echo "Unsupported architecture: $arch" >&2
    exit 1
  fi
}

check_factorio_dlc() {
  local location
  if [ "$(get_os)" == "macos" ]; then
    location="$1/factorio.app/Contents/data"
  else
    location="$1/data"
  fi

  if [ "$SPACE_AGE_ENABLE" == "true" ] && [ ! -d "$location/space-age" ]; then
    echo "false"
    return
  fi
  if [ "$ELEVATED_RAILS_ENABLE" == "true" ] && [ ! -d "$location/elevated-rails" ]; then
    echo "false"
    return
  fi
  if [ "$QUALITY_ENABLE" == "true" ] && [ ! -d "$location/quality" ]; then
    echo "false"
    return
  fi
  echo "true"
}

get_local_factorio_version() {
  local binary
  if [ "$(get_os)" == "macos" ]; then
    binary="$1/factorio.app/Contents/MacOS/factorio"
  else
    binary="$1/bin/x64/factorio"
  fi

  if [ -e "$binary" ]; then
    "$binary" --version | grep -oE 'Version: ([0-9]+\.[0-9]+\.[0-9]+)' | awk '{print $2}'
  else
    echo "false"
  fi
}

download_factorio() {
  local build
  if [[ "$SPACE_AGE_ENABLE" == "true" || "$ELEVATED_RAILS_ENABLE" == "true" || "$QUALITY_ENABLE" == "true" ]]; then
    build="expansion"
  else
    build="alpha"
  fi

  if [ "$(get_os)" == "macos" ]; then
    for base in "/Applications" "$FACTORIO_DIRECTORY"; do
      appPath="$base/factorio.app"
      if [[ -d "$appPath" ]] && \
         [[ "$(check_factorio_dlc "$base")" == "true" ]] && \
         [[ "$(get_local_factorio_version "$base")" == "$VERSION" ]]; then
        echo "Factorio is already installed in $appPath"
        FACTORIO_CLI="$appPath/Contents/MacOS/factorio"
        [ -z "$(find "$FACTORIO_DIRECTORY" -mindepth 1 -print -quit)" ] && rm -rf "$FACTORIO_DIRECTORY"
        FACTORIO_DIRECTORY="$base"
        return 0
      fi
    done

    echo "Downloading Factorio $VERSION $build for macOS..."
    local dmg_path="$FACTORIO_DIRECTORY/factorio.dmg"
    local download_url="https://www.factorio.com/get-download/$VERSION/$build/osx?username=$FACTORIO_USERNAME&token=$FACTORIO_TOKEN"
    local http_code
    http_code=$(curl -L -w "%{http_code}" -s -o "$dmg_path" "$download_url")

    if [ "$http_code" -eq 403 ]; then
      echo "Account information not provided or you do not have permission to download." >&2
      exit 1
    fi

    echo "Unpacking Factorio $VERSION $build for macOS..."
    rm -rf "$FACTORIO_DIRECTORY/factorio.app"
    local volume
    volume=$(hdiutil attach "$dmg_path" -noverify | tail -1 | awk '{print $3}')
    cp -r "$volume/"*.app "$FACTORIO_DIRECTORY/"
    diskutil unmount "$volume" > /dev/null 2>&1
    rm "$dmg_path"

    echo "Factorio $VERSION $build downloaded and installed in $FACTORIO_DIRECTORY"
    FACTORIO_CLI="$FACTORIO_DIRECTORY/factorio.app/Contents/MacOS/factorio"
  else
    if [[ -d "$FACTORIO_DIRECTORY" ]] && \
       [[ "$(get_local_factorio_version "$FACTORIO_DIRECTORY")" == "$VERSION" ]]; then
      echo "Factorio is already installed in $FACTORIO_DIRECTORY"
      FACTORIO_CLI="$FACTORIO_DIRECTORY/bin/x64/factorio"
      return 0
    fi

    rm -rf "$FACTORIO_DIRECTORY"/*
    echo "Downloading Factorio $VERSION $build for Linux..."
    local http_code
    http_code=$(curl -s -w "%{http_code}" -o "$FACTORIO_DIRECTORY/factorio.tar.xz" \
      -L "https://www.factorio.com/get-download/$VERSION/headless/linux64")

    if [ "$http_code" -eq 429 ]; then
      echo "Rate limit exceeded. Please try again later." >&2
      rm -rf "$FACTORIO_DIRECTORY/factorio.tar.xz"
      exit 1
    fi

    echo "Unpacking Factorio $VERSION $build for Linux..."
    tar -xJvf "$FACTORIO_DIRECTORY/factorio.tar.xz" -C "$FACTORIO_DIRECTORY" &>/dev/null
    mv "$FACTORIO_DIRECTORY/factorio/"* "$FACTORIO_DIRECTORY"
    rm -rf "$FACTORIO_DIRECTORY/factorio" "$FACTORIO_DIRECTORY/factorio.tar.xz"

    echo "Factorio $VERSION $build downloaded and installed in $FACTORIO_DIRECTORY"
    FACTORIO_CLI="$FACTORIO_DIRECTORY/bin/x64/factorio"
  fi
}

server_setting() {
  local data="$FACTORIO_DIRECTORY/$( [ "$(get_os)" == "macos" ] && echo "factorio.app/Contents/data" || echo "data" )"

  if [ ! -f "$data/server-settings.json" ]; then
    cp "$data/server-settings.example.json" "$DATA_DIRECTORY/server-settings.json"
  fi

  local map_zip="$DATA_DIRECTORY/$MAP_NAME.zip"
  if [ ! -f "$map_zip" ]; then
    rm -rf "$DATA_DIRECTORY/mods/mod-list.json"
    local map_settings="$DATA_DIRECTORY/map-settings.json"
    local map_gen_settings="$DATA_DIRECTORY/map-gen-settings.json"
    [ ! -f "$map_settings" ] && cp "$data/map-settings.example.json" "$map_settings"
    [ ! -f "$map_gen_settings" ] && cp "$data/map-gen-settings.example.json" "$map_gen_settings"
    sudo -u "$USER" "$FACTORIO_CLI" \
      --create "$map_zip" \
      --map-gen-settings "$map_gen_settings" \
      --map-settings "$map_settings"
  fi
}

set_chown() {
  chown -R "$USER" "$DATA_DIRECTORY" "$FACTORIO_DIRECTORY" "$LIBRARY_DIRECTORY"
}

mod_setting() {
  local mod_dir="$DATA_DIRECTORY/mods"
  local mod_file="$mod_dir/mod-list.json"
  mkdir -p "$mod_dir"

  # If space-age is enabled, force dependent mods enabled.
  [ "$SPACE_AGE_ENABLE" = "true" ] && {
    QUALITY_ENABLE=true
    ELEVATED_RAILS_ENABLE=true
  }

  if [ -f "$mod_file" ]; then
    local prev_data prev_enabled
    prev_data=$("$LIBRARY_DIRECTORY/jq" '.' "$mod_file")
    for mod in "elevated-rails" "quality" "space-age"; do
      prev_enabled=$(echo "$prev_data" | "$LIBRARY_DIRECTORY/jq" -r --arg mod "$mod" '.mods[] | select(.name == $mod) | .enabled')
      if [ "$prev_enabled" = "true" ]; then
        case "$mod" in
          "elevated-rails")
            if [ "$ELEVATED_RAILS_ENABLE" != "true" ]; then
              echo "You cannot disable elevated-rails when it was enabled." >&2
              ELEVATED_RAILS_ENABLE=true
            fi
            ;;
          "quality")
            if [ "$QUALITY_ENABLE" != "true" ]; then
              echo "You cannot disable quality when it was enabled." >&2
              QUALITY_ENABLE=true
            fi
            ;;
          "space-age")
            if [ "$SPACE_AGE_ENABLE" != "true" ]; then
              echo "You cannot disable space-age when it was enabled." >&2
              SPACE_AGE_ENABLE=true
            fi
            ;;
        esac
      fi
    done
  fi

  cat > "$mod_file" <<EOF
{
  "mods": [
    {"name": "base", "enabled": true},
    {"name": "elevated-rails", "enabled": $( [ "$ELEVATED_RAILS_ENABLE" = "true" ] && echo "true" || echo "false" )},
    {"name": "quality", "enabled": $( [ "$QUALITY_ENABLE" = "true" ] && echo "true" || echo "false" )},
    {"name": "space-age", "enabled": $( [ "$SPACE_AGE_ENABLE" = "true" ] && echo "true" || echo "false" )}
  ]
}
EOF
}

start_server() {
  local whitelist_opts=""
  if [ "$WHITELIST_ENABLE" = "true" ]; then
    whitelist_opts="--use-server-whitelist --server-whitelist $DATA_DIRECTORY/server-whitelist.json"
  fi

  sudo -u "$USER" "$FACTORIO_CLI" \
    --start-server "$DATA_DIRECTORY/$MAP_NAME.zip" \
    --server-settings "$DATA_DIRECTORY/server-settings.json" \
    --mod-directory "$DATA_DIRECTORY/mods" \
    --port "$PORT" \
    $whitelist_opts \
    --server-banlist "$DATA_DIRECTORY/server-banlist.json" \
    --server-adminlist "$DATA_DIRECTORY/server-adminlist.json" \
    --console-log "$DATA_DIRECTORY/factorio-current.log" \
    --server-id "$DATA_DIRECTORY/server-id.json"
}

handle_argument "$@"
set_timezone
directory_setting
create_group_user

install_jq
get_factorio_version
check_factorio_version_exist
check_arch
download_factorio
set_chown
server_setting
mod_setting
set_chown
start_server
