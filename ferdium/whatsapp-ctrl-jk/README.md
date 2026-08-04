# Ctrl+J/K conversation navigation for Ferdium

These Ferdium `user.js` scripts add Doom-style conversation navigation to
three services:

- `Ctrl+J`: next chat
- `Ctrl+K`: previous chat

Telegram and WhatsApp invoke the same page handlers as selecting the adjacent
chat row. Slack rewrites the original trusted key event to its native
`Alt+Down/Up` shortcut.

The portable service handlers live at the top level. Optional OS-specific
extensions live under `platforms/`; the uniform installer detects the host OS
and installs the matching extension automatically. The macOS Slack extension
handles the Ferdium-scoped `Cmd+H/L` bridge and cycles focus through the
conversation list, primary chat, and thread/AI pane.

## Install

Run:

```sh
./install.sh
```

Install or update only selected services:

```sh
./install.sh telegram
./install.sh whatsapp slack
```

The installer detects the Ferdium profile directory:

- Linux: `${XDG_CONFIG_HOME:-~/.config}/Ferdium`
- macOS: `~/Library/Application Support/Ferdium`

Set `FERDIUM_PROFILE_DIR` to override detection.

The installer uses Ferdium's supported per-recipe `user.js` extension point,
which injects a service-specific handler into the page's main JavaScript
world. It removes the older generated-recipe patches, preserves any existing
`user.js` as `user.js.before-ctrl-jk`, and installs the current scripts.

Load and key handling diagnostics are appended to:

```text
macOS: ~/Library/Logs/Ferdium/ctrl-jk.log
Linux: ${XDG_STATE_HOME:-~/.local/state}/Ferdium/ctrl-jk.log
```

Reload the updated Ferdium services after installation.
