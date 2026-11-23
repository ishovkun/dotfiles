#!/usr/bin/env python3
"""Sync the Inference Hub model lists in Zed and opencode from the hub itself.

    sync-hub-models            # dry run: show what would change
    sync-hub-models --apply    # rewrite both configs (backups first)

Fetches GET /v1/models with $INFERENCEHUB_TOKEN, keeps only the model lines
listed in LINES below (no flash/lite/mini/nano/haiku/luna), keeps the newest
KEEP versions of each line per route, and rewrites:

  * Zed:      language_models.openai_compatible."Inference Hub".available_models
  * opencode: provider."inference-hub".models

Only those two JSON values are replaced; comments and every other setting in
both files are left byte-for-byte alone.  A model's capabilities and
reasoning-effort variants are copied from the closest already-configured
model of the same line (same route first), so a new version of a family you
already use needs no hand edits.  Hub ids that look like a new top-tier line
are reported and skipped until a pattern is added to LINES.

The token is read from the environment and never printed or written anywhere.
"""
import argparse, copy, json, os, re, shutil, sys, time, urllib.request

HUB = "https://inference-api.nvidia.com/v1/models"
KEEP = 2
ZED = os.path.expanduser("~/.config/zed/settings.json")
OPENCODE = os.path.expanduser("~/.config/opencode/opencode.jsonc")
BACKUP_DIR = os.path.expanduser("~/.local/state/sync-hub-models")

V = r"(\d+(?:[.-]\d+)?)"  # 5, 5.5, 5-5

# (id regex, line key, pretty-name builder).  Group "route" and "v" required.
LINES = [
    (rf"^(?P<route>aws|azure)/anthropic/(?:bedrock-)?claude-(?P<tier>opus|sonnet)-(?P<v>{V[1:-1]})$",
     "claude-{tier}", lambda m, v: f"Claude {m['tier'].title()} {v}"),
    (rf"^(?P<route>openai|azure)/openai/gpt-(?P<v>{V[1:-1]})-(?P<tier>sol|astra|terra)$",
     "gpt-{tier}", lambda m, v: f"GPT-{v} {m['tier'].title()}"),
    (rf"^(?P<route>openai|azure)/openai/gpt-(?P<v>{V[1:-1]})-codex$",
     "gpt-codex", lambda m, v: f"GPT-{v} Codex"),
    (rf"^(?P<route>gcp)/google/gemini-(?P<v>{V[1:-1]})-(?P<tier>pro-preview|pro|argon)$",
     "gemini-top", lambda m, v: f"Gemini {v} " + m["tier"].replace("-", " ").title()),
    (rf"^(?P<route>xai)/xai/grok-(?P<v>{V[1:-1]})$",
     "grok", lambda m, v: f"Grok {v}"),
    (rf"^(?P<route>nvidia)/deepseek-ai/deepseek-v(?P<v>{V[1:-1]})-pro$",
     "deepseek-pro", lambda m, v: f"DeepSeek V{v} Pro"),
    (rf"^(?P<route>nvidia)/moonshotai/kimi-k(?P<v>{V[1:-1]})(?P<tier>-pro)?$",
     "kimi", lambda m, v: f"Kimi K{v}" + (" Pro" if m["tier"] else "")),
    (rf"^(?P<route>nvidia)/zai-org/glm-(?P<v>{V[1:-1]})$",
     "glm", lambda m, v: f"GLM {v}"),
]
ROUTES = {"aws", "azure", "openai", "gcp", "nvidia", "xai"}
CHEAP = re.compile(r"flash|lite|mini|nano|haiku|luna|-chat$")
FAMILY = re.compile(r"claude|gpt-\d|gemini|grok|deepseek|kimi|glm")
USABLE_MODES = {"chat", "responses", "completion", None}

FALLBACK_ZED = {"efforts": [None], "capabilities": {
    "tools": True, "images": False, "parallel_tool_calls": True, "prompt_cache_key": False}}
FALLBACK_OC = {"status": "active", "reasoning": False, "attachment": False, "tool_call": True,
               "modalities": {"input": ["text"], "output": ["text"]}}


# ---------------------------------------------------------------- JSONC I/O
def strip_jsonc(text):
    """Drop // and /* */ comments and trailing commas, respecting strings."""
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == '"':
            j = i + 1
            while j < n and text[j] != '"':
                j += 2 if text[j] == "\\" else 1
            out.append(text[i:j + 1]); i = j + 1
        elif text.startswith("//", i):
            i = text.find("\n", i); i = n if i < 0 else i
        elif text.startswith("/*", i):
            i = text.index("*/", i) + 2
        else:
            out.append(c); i += 1
    return re.sub(r",(\s*[}\]])", r"\1", "".join(out))


def load_jsonc(path):
    with open(path) as f:
        return json.loads(strip_jsonc(f.read()))


def value_span(text, key_path):
    """Return (start, end) of the JSON value at key_path inside JSONC text."""
    i, n = 0, len(text)

    def skip_ws(i):
        while i < n:
            if text[i].isspace(): i += 1
            elif text.startswith("//", i): i = text.find("\n", i); i = n if i < 0 else i
            elif text.startswith("/*", i): i = text.index("*/", i) + 2
            else: return i
        return i

    def read_str(i):
        j = i + 1
        while text[j] != '"':
            j += 2 if text[j] == "\\" else 1
        return json.loads(text[i:j + 1]), j + 1

    def skip_value(i):
        i = skip_ws(i)
        if text[i] == '"': return read_str(i)[1]
        if text[i] in "[{":
            depth = 0
            while True:
                i = skip_ws(i)
                c = text[i]
                if c == '"': i = read_str(i)[1]; continue
                if c in "[{": depth += 1
                elif c in "]}":
                    depth -= 1
                    if depth == 0: return i + 1
                i += 1
        m = re.compile(r"[^,\]}\s]+").match(text, i)
        return m.end()

    i = skip_ws(0)
    for key in key_path:
        assert text[i] == "{", f"expected object before {key!r}"
        i += 1
        while True:
            i = skip_ws(i)
            if text[i] == "}": raise KeyError(key)
            k, i = read_str(i)
            i = skip_ws(i); assert text[i] == ":"; i = skip_ws(i + 1)
            if k == key: break
            i = skip_ws(skip_value(i))
            if text[i] == ",": i += 1
    start = skip_ws(i)
    return start, skip_value(start)


def splice(path, key_path, value):
    with open(path) as f:
        text = f.read()
    s, e = value_span(text, key_path)
    line_start = text.rfind("\n", 0, s) + 1
    indent = re.match(r"[ \t]*", text[line_start:]).group(0)
    rendered = json.dumps(value, indent=2, ensure_ascii=False).replace("\n", "\n" + indent)
    return text[:s] + rendered + text[e:]


# ---------------------------------------------------------------- model logic
def vtuple(v):
    return tuple(int(x) for x in re.split(r"[.-]", v))


def vdot(v):
    return ".".join(str(x) for x in vtuple(v))


def classify(mid):
    for rx, line, pretty in LINES:
        m = re.match(rx, mid)
        if m:
            g = m.groupdict()
            return {"id": mid, "route": g["route"], "line": line.format(**g),
                    "v": vtuple(g["v"]), "pretty": pretty(g, vdot(g["v"]))}
    return None


def fetch_hub():
    tok = os.environ.get("INFERENCEHUB_TOKEN", "").strip().strip("\"'")
    if not tok:
        sys.exit("INFERENCEHUB_TOKEN is not set in this shell")
    req = urllib.request.Request(HUB, headers={"Authorization": f"Bearer {tok}"})
    with urllib.request.urlopen(req, timeout=30) as r:
        data = json.load(r)
    return data.get("data", data)


def select(hub):
    picked, unknown, by_line = {}, [], {}
    for m in hub:
        mid = m["id"]
        if m.get("mode") not in USABLE_MODES or mid.split("/")[0] not in ROUTES:
            continue
        c = classify(mid)
        if c is None:
            if FAMILY.search(mid) and not CHEAP.search(mid):
                unknown.append(mid)
            continue
        c["ctx"], c["out"] = m.get("max_input_tokens"), m.get("max_output_tokens")
        key = (c["route"], c["line"])
        best = by_line.setdefault(key, {})
        # Same version under two ids (e.g. aws claude with/without "bedrock-"):
        # prefer the bedrock- id, which is the one the hub actually serves chat on.
        if c["v"] not in best or "bedrock-" in mid:
            best[c["v"]] = c
    for key, versions in by_line.items():
        for v in sorted(versions, reverse=True)[:KEEP]:
            picked[versions[v]["id"]] = versions[v]
    return picked, sorted(unknown)


def sibling(c, configured):
    """Closest configured model of the same line: same route first, then any."""
    cands = [classify(x) for x in configured]
    cands = [x for x in cands if x and x["line"] == c["line"]]
    if not cands:
        return None
    cands.sort(key=lambda x: (x["route"] == c["route"], x["id"] == c["id"], x["v"]), reverse=True)
    return cands[0]["id"]


def order_key(c):
    lines = [l[1].split("{")[0] for l in LINES]
    base = next(i for i, l in enumerate(lines) if c["line"].startswith(l))
    return (base, c["line"], c["route"], tuple(-x for x in c["v"]))


def build_zed(picked, old_entries):
    groups = {}
    for e in old_entries:
        groups.setdefault(e["name"], []).append(e)
    out = []
    for c in sorted(picked.values(), key=order_key):
        sib = sibling(c, groups)
        tmpl = groups[sib] if sib else [dict(capabilities=FALLBACK_ZED["capabilities"])]
        for t in tmpl:
            e = copy.deepcopy(t)
            effort = t.get("reasoning_effort")
            name = f"{c['pretty']} [{c['route']}]" + (f" ({effort})" if effort else "")
            new = {"name": c["id"],
                   "max_tokens": c["ctx"] or t.get("max_tokens", 200000),
                   "max_output_tokens": c["out"] or t.get("max_output_tokens", 64000),
                   "display_name": name}
            if effort:
                new["reasoning_effort"] = effort
            new["capabilities"] = e.get("capabilities", FALLBACK_ZED["capabilities"])
            out.append(new)
    return out


def build_opencode(picked, old_models):
    out = {}
    for c in sorted(picked.values(), key=order_key):
        sib = sibling(c, old_models)
        e = copy.deepcopy(old_models[sib]) if sib else copy.deepcopy(FALLBACK_OC)
        e["name"] = f"{c['pretty']} [{c['route']}]"
        lim = e.get("limit", {})
        e["limit"] = {"context": c["ctx"] or lim.get("context", 200000),
                      "output": c["out"] or lim.get("output", 64000)}
        # keep a stable key order: name first
        out[c["id"]] = {"name": e.pop("name"), **e}
    return out


# ---------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--apply", action="store_true", help="write the configs (default: dry run)")
    args = ap.parse_args()

    picked, unknown = select(fetch_hub())

    zed_path = ["language_models", "openai_compatible", "Inference Hub", "available_models"]
    oc_path = ["provider", "inference-hub", "models"]
    zed_cfg, oc_cfg = load_jsonc(ZED), load_jsonc(OPENCODE)
    zed_old = zed_cfg
    for k in zed_path: zed_old = zed_old[k]
    oc_old = oc_cfg
    for k in oc_path: oc_old = oc_old[k]

    zed_new, oc_new = build_zed(picked, zed_old), build_opencode(picked, oc_old)

    old_ids = {e["name"] for e in zed_old} | set(oc_old)
    new_ids = set(picked)
    print(f"hub: {len(picked)} models selected (newest {KEEP} per line and route)\n")
    for label, ids in (("+ add", new_ids - old_ids), ("- drop", old_ids - new_ids),
                       ("  keep", new_ids & old_ids)):
        for mid in sorted(ids, key=lambda x: order_key(classify(x)) if classify(x) else (99,)):
            print(f"{label}  {mid}")
    if unknown:
        print("\nskipped, not in LINES (add a pattern if you want these):")
        for mid in unknown:
            print(f"   ?  {mid}")

    # Warn when a default model would disappear.
    defaults = []
    try: defaults.append(("zed agent.default_model", zed_cfg["agent"]["default_model"]["model"]))
    except KeyError: pass
    m = oc_cfg.get("model", "")
    if m.startswith("inference-hub/"): defaults.append(("opencode model", m.split("/", 1)[1]))
    for where, mid in defaults:
        if mid not in new_ids:
            print(f"\nWARNING: {where} = {mid} is not in the new list")

    if not args.apply:
        print("\ndry run; re-run with --apply to write")
        return

    os.makedirs(BACKUP_DIR, exist_ok=True)
    stamp = time.strftime("%Y%m%d-%H%M%S")
    for path, kp, val in ((ZED, zed_path, zed_new), (OPENCODE, oc_path, oc_new)):
        text = splice(path, kp, val)
        json.loads(strip_jsonc(text))  # refuse to write a file that doesn't parse
        bak = os.path.join(BACKUP_DIR, f"{os.path.basename(path)}.{stamp}")
        shutil.copy2(path, bak)
        # Write in place (not rename) so hard links into ~/dotfiles survive.
        with open(path, "r+") as f:
            f.seek(0); f.write(text); f.truncate()
        print(f"wrote {path}  (backup {bak})")


if __name__ == "__main__":
    main()
