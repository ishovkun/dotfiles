#!/usr/bin/env python3
"""tmux-resurrect post-save hook: record which agent session runs in each pane.

Writes <resurrect dir>/agents.json, mapping "session:window.pane" to the cwd
and exact resume command. Read back by agents-restore.py after `prefix C-r`.

Sources, all exact (no guessing):
  claude    ~/.claude/sessions/<pid>.json  -> sessionId, cwd (start dir)
  opencode  Bridge plugin registry ~/.local/state/bridge/opencode/<pid>-*.json
            -> ask that process's /global/health for its current session_id
  codex     open ~/.codex/sessions/**/rollout-*-<uuid>.jsonl file of the process
"""

from __future__ import annotations

import glob
import json
import os
import re
import subprocess
import sys
import urllib.parse
import urllib.request
from pathlib import Path

HOME = Path.home()


def sh(*args: str) -> str:
    return subprocess.run(args, capture_output=True, text=True).stdout


def process_table() -> tuple[dict[int, str], dict[int, list[int]]]:
    args: dict[int, str] = {}
    kids: dict[int, list[int]] = {}
    for line in sh("/bin/ps", "-axo", "pid=,ppid=,args=").splitlines():
        parts = line.split(None, 2)
        if len(parts) < 3:
            continue
        pid, ppid = int(parts[0]), int(parts[1])
        args[pid] = parts[2]
        kids.setdefault(ppid, []).append(pid)
    return args, kids


def descendants(pid: int, kids: dict[int, list[int]]) -> list[int]:
    out, stack = [], [pid]
    while stack:
        p = stack.pop()
        out.append(p)
        stack.extend(kids.get(p, []))
    return out


def claude_sessions() -> dict[int, dict]:
    out = {}
    for f in glob.glob(str(HOME / ".claude/sessions/*.json")):
        try:
            d = json.loads(Path(f).read_text())
            out[int(d["pid"])] = d
        except (OSError, ValueError, KeyError):
            pass
    return out


def opencode_session(pid: int) -> tuple[str, str] | None:
    for f in glob.glob(str(HOME / f".local/state/bridge/opencode/{pid}-*.json")):
        try:
            reg = json.loads(Path(f).read_text())
            q = urllib.parse.urlencode({"directory": reg["directory"]})
            req = urllib.request.Request(
                f"{reg['url']}/global/health?{q}",
                headers={"Authorization": f"Bearer {reg['token']}"},
            )
            with urllib.request.urlopen(req, timeout=3) as r:
                sid = json.load(r)["bridge"]["session_id"]
            if sid:
                return sid, reg["directory"]
        except Exception:
            continue
    return None


ROLLOUT = re.compile(r"/\.codex/sessions/\S*rollout-\S*?([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\.jsonl")


def codex_session(pids: list[int]) -> str | None:
    for p in pids:
        m = ROLLOUT.search(sh("lsof", "-p", str(p)))
        if m:
            return m.group(1)
    return None


def main() -> int:
    resurrect_dir = Path(sys.argv[1]).parent if len(sys.argv) > 1 else HOME / ".local/share/tmux/resurrect"
    args, kids = process_table()
    claude = claude_sessions()
    panes = sh("tmux", "list-panes", "-a", "-F",
               "#{session_name}:#{window_index}.#{pane_index}\t#{pane_pid}\t#{pane_current_path}")
    agents = {}
    for line in panes.splitlines():
        target, pane_pid, path = line.split("\t")
        tree = descendants(int(pane_pid), kids)
        entry = None
        for p in tree:
            a = args.get(p, "")
            if p in claude and "--output-format" not in a:
                d = claude[p]
                entry = {"agent": "claude", "cwd": d["cwd"],
                         "cmd": f"claude --resume {d['sessionId']}"}
                break
            if re.match(r"(\S*/)?opencode(\s|$)", a) and " serve" not in a:
                got = opencode_session(p)
                if got:
                    entry = {"agent": "opencode", "cwd": got[1],
                             "cmd": f"opencode -s {got[0]}"}
                break
            if re.search(r"(^|/)codex(\s|$)", a) or re.search(r"/bin/codex\s", a):
                sid = codex_session(descendants(p, kids))
                if sid:
                    entry = {"agent": "codex", "cwd": path,
                             "cmd": f"codex resume {sid}"}
                break
        if entry:
            agents[target] = entry
    out = resurrect_dir / "agents.json"
    tmp = out.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(agents, indent=2) + "\n")
    os.replace(tmp, out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
