# WhatsApp Ctrl+J/K navigation for Ferdium

This patch adds Doom-style chat navigation to Ferdium's WhatsApp recipe:

- `Ctrl+J`: next chat
- `Ctrl+K`: previous chat

It runs inside WhatsApp's page context and invokes the same React
`onMouseDown` handler as clicking a chat row. This avoids slower
system-level modifier remapping and works on Linux and macOS.

## Install

Close Ferdium, then run:

```sh
./install.sh
```

The installer detects Ferdium's profile directory:

- Linux: `${XDG_CONFIG_HOME:-~/.config}/Ferdium`
- macOS: `~/Library/Application Support/Ferdium`

Set `FERDIUM_PROFILE_DIR` to override detection.

The installer backs up `webview-unsafe.js`, replaces an older copy of this
patch if present, and leaves the rest of the downloaded WhatsApp recipe
untouched. Rerun it if a Ferdium recipe update overwrites the patch.
