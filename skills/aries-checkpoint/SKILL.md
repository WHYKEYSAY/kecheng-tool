---
name: durable-checkpoint
description: Distill the current session's durable, useful state into an external "brain" folder (a synced or version-controlled directory) so the next session — on this machine or any other — wakes up with it. Use when the user says "checkpoint", "save context", the session is wrapping up, or before a context compaction.
---

# Durable checkpoint — flush what matters into an external brain

This is a pattern for giving an agent persistent memory across sessions and machines, without relying on any one session's context window. Point it at your own "brain" location — a git repo, a synced folder (Nextcloud/Dropbox/iCloud), or any durable storage the agent can write to and future sessions can read from.

## What to capture (durable only)
Checkpoint what a fresh session would need but can't derive from the repo/git history:
- **Decisions + their why** (not just what changed — the reasoning).
- **Current state / open threads** (what's in flight, what's blocked and on whom).
- **Gotchas** learned this session (a pitfall, a non-obvious constraint, a "don't do X").
- **Pointers** to where the real artifacts are (repo, PR, file) — not their contents.

Do **not** checkpoint: what's already in code/git/project-instructions files, secrets, or conversation-only trivia. If it's a lasting *fact* about you or your preferences, it belongs in a separate long-lived memory/profile file, not a checkpoint. If it's *session state / a thread*, it belongs here.

## How to write it
1. Draft a tight checkpoint body (markdown; a few bullets, link related notes by name).
2. Pick a slug (short-kebab) and a tag: `active` (ongoing) · `done` (closed) · `deadend` (tried, no) · `conjectured` · `validated`.
3. Write it through a small gated writer script (never edit the files by hand from inside a live session — a script keeps the format consistent and lets you enforce append-only history):
   ```sh
   printf '%s\n' "<body>" | bash "<BRAIN_ROOT>/scripts/checkpoint.sh" <slug> <tag>
   ```
   A minimal version of that script: stamp the body into a new file under `checkpoints/<date>-<slug>.md`, prepend a one-line entry to a running `ledger/LEDGER.md`, and regenerate a short `NOW.md` summarizing the most recent/open items (this is the file a fresh session reads first).
4. If open threads changed, also update the **## Open threads** section of `NOW.md` directly — that's what the next session sees first — keep it short and current, not a transcript.
5. If you've accumulated several checkpoints, rebuild a lightweight index/catalog file so old ones stay discoverable by topic.
6. Commit the brain repo with your own identity (not the agent's) if it's version-controlled.

## Wiring it into session start
If your brain lives in a git repo or synced folder, load `NOW.md` (or equivalent) at the start of every session — via a `SessionStart` hook (Claude Code), an `AGENTS.md`/steering-file pointer (Codex/Kiro), or simply telling the agent to read it first thing. That's what turns a pile of checkpoint files into an agent that "remembers" across sessions and machines.

Keep checkpoints few and high-signal — the brain is a headline board, not a transcript.
