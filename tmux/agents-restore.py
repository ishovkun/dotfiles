#!/usr/bin/env python3
"""tmux-resurrect post-restore-all hook: relaunch agents into restored panes.

Reads <resurrect dir>/agents.json written by agents-save.py. For each pane:
  - skip it if the pane is missing or already runs something (not a shell),
    so pressing prefix C-r twice never doubles an agent
  - otherwise cd into the session's start dir and run the resume command
"""

from __future__ import annotations

import json
import shlex
import subprocess
import sys
from pathlib import Path

SHELLS = {"zsh", "bash", "sh", "fish", "-zsh", "-bash"}
AGENTS = Path.home() / ".local/share/tmux/resurrect/agents.json"


def tmux(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["tmux", *args], capture_output=True, text=True)


def main() -> int:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else AGENTS
    if not path.exists():
        return 0
    agents = json.loads(path.read_text())
    started = 0
    for target, entry in agents.items():
        current = tmux("display-message", "-p", "-t", target, "#{pane_current_command}")
        if current.returncode != 0:
            continue
        if current.stdout.strip() not in SHELLS:
            continue
        line = f"cd {shlex.quote(entry['cwd'])} && {entry['cmd']}"
        tmux("send-keys", "-t", target, line, "Enter")
        started += 1
    tmux("display-message", f"agents restored: {started}/{len(agents)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
