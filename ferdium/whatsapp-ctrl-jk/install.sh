#!/bin/sh

set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
snippet_file="$script_dir/webview-unsafe-snippet.js"

if [ -n "${FERDIUM_PROFILE_DIR:-}" ]; then
  profile_dir=$FERDIUM_PROFILE_DIR
elif [ "$(uname -s)" = "Darwin" ]; then
  profile_dir="$HOME/Library/Application Support/Ferdium"
else
  profile_dir="${XDG_CONFIG_HOME:-$HOME/.config}/Ferdium"
fi

recipe_file="$profile_dir/recipes/whatsapp/webview-unsafe.js"

if [ ! -f "$recipe_file" ]; then
  printf 'WhatsApp recipe not found: %s\n' "$recipe_file" >&2
  printf 'Open WhatsApp in Ferdium once, then rerun this installer.\n' >&2
  exit 1
fi

backup_file="$recipe_file.before-ctrl-jk"
if [ ! -e "$backup_file" ]; then
  cp -p "$recipe_file" "$backup_file"
fi

temp_file=$(mktemp "${TMPDIR:-/tmp}/ferdium-whatsapp-ctrl-jk.XXXXXX")
trap 'rm -f "$temp_file"' EXIT HUP INT TERM

awk '
  $0 == "// BEGIN dotfiles: whatsapp-ctrl-jk" {
    in_patch = 1
    next
  }
  $0 == "// END dotfiles: whatsapp-ctrl-jk" {
    in_patch = 0
    next
  }
  !in_patch {
    print
  }
' "$recipe_file" >"$temp_file"

printf '\n' >>"$temp_file"
sed -n '/^\/\/ BEGIN dotfiles: whatsapp-ctrl-jk$/,$p' "$snippet_file" \
  >>"$temp_file"

cp "$temp_file" "$recipe_file"
printf 'Installed WhatsApp Ctrl+J/K navigation in:\n%s\n' "$recipe_file"
printf 'Restart Ferdium or reload WhatsApp with Ctrl+R.\n'
