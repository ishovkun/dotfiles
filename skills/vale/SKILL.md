---
name: vale
description: Lint prose for AI-sounding phrasing with Vale and rewrite until clean. Use when invoked as /vale, or when asked to check a doc, design proposal, README or PR description for AI slop, chat residue, or wording that reads machine-written. Works on .md, .txt, .typ and .rst files.
---

# Vale prose lint

Vale is installed globally with `~/.vale.ini` (from `~/dotfiles/vale`). It runs
two styles: `ai-tells` (generic AI phrasing) and `Igor` (chat residue, leaks of
how the doc was made, outline run-in labels, the section sign, sentences that read like
code steps, banned terms). Typst is linted as Markdown.

## Run

```sh
vale FILE                                   # full report
vale --output line FILE                     # file:line:col:rule:message
vale --output line FILE | cut -d: -f4 | sort | uniq -c | sort -rn   # counts per rule
```

If `vale` reports a missing style, run `vale sync` once from any directory.

## Iterate

Edit, run, edit until the count is near zero. Then report the final counts per
rule and every hit you left, each with a one-line reason.

- Fix every `Igor.*` hit and every `ai-tells` hit in running prose by rewriting
  the sentence the way an engineer would write it.
- Break chained clauses (`SemicolonUsage`) and stock three-part lists
  (`VerbTricolon`) into plain sentences. Keep a semicolon only where two short
  clauses belong together.
- You may leave these when the sentence is already plain; they report false hits on
  systems prose because they match ordinary usage: `NegatedObject` ("needs no slot"), `NegatedSubject`,
  `FormalTransitions` ("for example"), `AnthropomorphicCognition` ("a viewer
  wants"), and any hit inside tables of data or code blocks.
- `Igor.BannedTerms` ("rollout") is fine inside a quote of another project's
  own term.

## Do not

- Turn rules off: no Vale comments, no edits to `~/.vale.ini` or the styles
  unless the user asks.
- Swap a flagged word for a synonym that says the same thing worse, or chop a
  sentence into fragments to get under a rule.
- Change defined terms, API names or decisions while rewording.
- Shrink fonts or margins to make up for longer text.

## New tells

Report slop the rules miss as a proposed rule
(phrase or regex, plus why). Add it to `~/dotfiles/vale/styles/Igor/` only when
the user says so.
