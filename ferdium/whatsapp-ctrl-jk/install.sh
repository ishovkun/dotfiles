#!/bin/sh

set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

if [ -n "${FERDIUM_PLATFORM:-}" ]; then
  platform=$FERDIUM_PLATFORM
elif [ "$(uname -s)" = "Darwin" ]; then
  platform=macos
else
  platform=linux
fi

case "$platform" in
  macos|linux) ;;
  *)
    printf 'Unsupported platform: %s\n' "$platform" >&2
    exit 1
    ;;
esac

if [ -n "${FERDIUM_PROFILE_DIR:-}" ]; then
  profile_dir=$FERDIUM_PROFILE_DIR
elif [ "$platform" = "macos" ]; then
  profile_dir="$HOME/Library/Application Support/Ferdium"
else
  profile_dir="${XDG_CONFIG_HOME:-$HOME/.config}/Ferdium"
fi

remove_legacy_patch() {
  service=$1
  recipe_name=$2
  marker_name=$3

  recipe_file="$profile_dir/recipes/$service/$recipe_name"
  begin_marker="// BEGIN dotfiles: $marker_name"
  end_marker="// END dotfiles: $marker_name"

  if [ ! -f "$recipe_file" ]; then
    return
  fi

  if ! grep -Fqx "$begin_marker" "$recipe_file"; then
    return
  fi

  temp_file=$(mktemp "${TMPDIR:-/tmp}/ferdium-ctrl-jk.XXXXXX")
  awk -v begin="$begin_marker" -v end="$end_marker" '
    $0 == begin {
      in_patch = 1
      next
    }
    $0 == end {
      in_patch = 0
      next
    }
    !in_patch {
      print
    }
  ' "$recipe_file" >"$temp_file"

  cp "$temp_file" "$recipe_file"
  rm -f "$temp_file"
}

install_user_script() {
  service=$1
  page_script_name=$2
  recipe_dir="$profile_dir/recipes/$service"
  user_file="$recipe_dir/user.js"
  user_script_file="$script_dir/user.js"
  page_script_file="$script_dir/$page_script_name"
  platform_page_file="$script_dir/platforms/$platform/$page_script_name"
  installed_platform_page="$recipe_dir/ctrl-jk-platform-page.js"
  platform_host_file="$script_dir/platforms/$platform/$service-host.js"
  installed_host_file="$recipe_dir/ctrl-jk-host.js"

  if [ ! -d "$recipe_dir" ]; then
    printf '%s recipe not found: %s\n' "$service" "$recipe_dir" >&2
    printf 'Open the service in Ferdium once, then rerun this installer.\n' >&2
    return 1
  fi

  if [ -f "$user_file" ] && [ ! -e "$user_file.before-ctrl-jk" ]; then
    cp -p "$user_file" "$user_file.before-ctrl-jk"
  fi

  cp "$user_script_file" "$user_file"
  cp "$page_script_file" "$recipe_dir/ctrl-jk-page.js"
  if [ -f "$platform_page_file" ]; then
    cp "$platform_page_file" "$installed_platform_page"
  elif [ -f "$installed_platform_page" ]; then
    rm -f "$installed_platform_page"
  fi
  if [ -f "$platform_host_file" ]; then
    cp "$platform_host_file" "$installed_host_file"
  elif [ -f "$installed_host_file" ]; then
    rm -f "$installed_host_file"
  fi
  printf 'Installed %s Ctrl+J/K user script in:\n%s\n' "$service" "$user_file"
}

install_service() {
  service=$1

  case "$service" in
    whatsapp)
      remove_legacy_patch whatsapp webview-unsafe.js whatsapp-ctrl-jk
      install_user_script whatsapp whatsapp-page.js
      ;;
    telegram)
      remove_legacy_patch telegram webview.js telegram-ctrl-jk
      install_user_script telegram telegram-page.js
      ;;
    slack)
      remove_legacy_patch slack webview.js slack-ctrl-jk
      install_user_script slack slack-page.js
      ;;
    *)
      printf 'Unknown service: %s\n' "$service" >&2
      return 1
      ;;
  esac
}

if [ "$#" -eq 0 ]; then
  set -- whatsapp telegram slack
fi

status=0
for service in "$@"; do
  install_service "$service" || status=1
done

if [ "$status" -ne 0 ]; then
  exit "$status"
fi

printf 'Reload the updated Ferdium service(s) to activate the scripts.\n'
