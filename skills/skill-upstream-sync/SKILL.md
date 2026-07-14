---
name: skill-upstream-sync
description: >-
  Periodically check whether the upstream repos that installed skills came from have new commits,
  and report what changed so they can be refreshed. Use when the user says "check skills for
  updates", "scan the skill repos", "are my skills up to date", or on a recurring cadence to keep
  externally-sourced skills (e.g. loop-engineering) current. Report-only by design — it never
  auto-pulls untrusted upstream code.
---

# Skill Upstream Sync

Skills installed from external GitHub repos drift out of date as upstream moves. This skill detects
that drift and reports it — it does **not** auto-apply changes (pulling third-party code
unreviewed is a supply-chain risk; this stays L1 "report-only" per loop-engineering).

## How it works

- A manifest at `~/.claude/skills/_upstream.json` records each externally-sourced skill → its
  `repo`, `branch`, and the `last_sha` seen when it was installed/last refreshed.
- `scan.sh` (in this skill's dir) `git ls-remote`s each repo's branch head and compares to
  `last_sha`. It prints, per skill: up-to-date, or `⬆ UPDATED` with a GitHub `compare/<old>...<new>`
  URL.

## Run it

```bash
bash ~/.claude/skills/skill-upstream-sync/scan.sh
```

## When something is UPDATED — the refresh flow (only on user approval)

1. **Open the `compare/` URL** and review the diff. Treat upstream as untrusted — read what changed.
2. If the change is wanted, re-fetch the skill's content (the SKILL.md / files this skill captures)
   and update `~/.claude/skills/<name>/`.
3. **Bump** that skill's `last_sha` (and `last_checked`) in `_upstream.json`.
4. Re-copy the refreshed skill into `Library/assets/skills/<name>/` (the [[skills-go-to-library]]
   convention).
5. Tell the user what changed and what you refreshed.

Never skip step 1. Never auto-pull on a schedule.

## Registering a new skill for tracking

Whenever a skill is added from an external repo, add an entry to `~/.claude/skills/_upstream.json`:

```json
"<skill-name>": {
  "repo": "https://github.com/<org>/<repo>",
  "branch": "main",
  "last_sha": "<current HEAD sha from: git ls-remote <repo> main>",
  "last_checked": "<YYYY-MM-DD>",
  "trust": "third-party (untrusted org) — review diffs before refreshing"
}
```

This is the standing rule: **a skill sourced from a repo is not fully installed until it's in the
manifest** — otherwise this scanner can't watch it.

## Cadence

Skill repos move slowly; a weekly check is plenty. It can be driven by a scheduler (local cron or a
cloud routine) that runs `scan.sh` and surfaces only the `⬆ UPDATED` lines. Currently tracking:
**loop-engineering** (cobusgreyling/loop-engineering).
