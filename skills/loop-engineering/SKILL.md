---
name: loop-engineering
description: >-
  Design and operate autonomous agent loops — recurring, self-directed agent runs that work
  toward a goal until done, instead of one-off manual prompts. Use when the user wants to set up
  scheduled/unattended automation (daily triage, PR babysitting, CI/dependency sweeps, changelog
  drafting, issue triage), stand up a self-running maintenance loop on a repo, or decide how much
  autonomy + which safety gates a loop should have. Distilled from cobusgreyling/loop-engineering.
---

# Loop Engineering

A "loop" is a recurring, goal-directed agent run that iterates until the goal is met (or it hands
off to a human) — you design the *system that runs the agent* rather than prompting by hand each
time. The discipline: layer loops by autonomy, isolate every code-change attempt, require a
verifier before any action, gate risky changes behind a human, and keep live state in one file.

## Autonomy levels — always start low, earn the next

- **L1 — Report / draft only.** The loop observes and writes a draft (a triage summary, a changelog
  draft, a findings list). A human reads and decides. No repo mutation. Start here for any new loop.
- **L2 — Assisted.** The loop may make changes, but each attempt runs in an **isolated git worktree**
  and a **verifier must pass** before anything is proposed. No auto-merge by default; a human gates.
- **L3 — Unattended.** Only after L2 has proven trustworthy on a narrow scope, and only for changes
  on an explicit allowlist (e.g. low-risk dependency patches) with a verifier. Everything else stays
  human-gated.

Roll out phased: L1 → (trust) → L2 → (trust) → L3. Never jump straight to unattended.

## The building blocks

1. **Scheduling / automation** — what triggers the loop (cron, GitHub Actions, a watcher). Match
   cadence to value vs token cost: daily for triage, every 10–15 min for active PR babysitting,
   6h–1d for dependency sweeps. Off-peak for cleanup/changelog.
2. **Worktrees** — every unattended code-change experiment runs in its own throwaway git worktree,
   one per attempt. Discard the worktree on verifier REJECT or human escalation. This is the core
   isolation guarantee — non-negotiable for L2+.
3. **Skills** — persistent project knowledge the loop reuses each run (conventions, where things
   live, how to verify).
4. **Connectors (MCP)** — scope to **read + comment only** until the loop is trusted; e.g. GitHub
   MCP read-only for discovery during L1 triage.
5. **Sub-agents** — fan out independent work; keep the conclusion, not the file dumps.
6. **Memory / State** — one `STATE.md` at repo root holds live loop state (what's pending, what's
   paused). Run history appends to a `loop-run-log.md`; token caps live in `loop-budget.md`.

## The 7 production patterns

| Pattern | Level | Cadence | Notes |
|---|---|---|---|
| Daily Triage | L1 | daily (weekdays) | report-only; updates STATE.md; human decides actions |
| PR Babysitter | L2 | 10–15 min, active hours | worktree fixes, verifier required, no auto-merge |
| Dependency Sweeper | L2 | 6h–1d | patch + low-risk CVE only; full `ci && test` in worktree; humans gate majors |
| CI Sweeper / Post-Merge | L1/L2 | opportunistic | validate + post a loop-readiness score on PRs |
| Changelog Drafter | L1 | daily / on release | draft-only → `RELEASE_NOTES_DRAFT.md` for approval |
| Post-Merge Cleanup | L1/L2 | off-peak | tidy branches/artifacts after merge |
| Issue Triage | L1 | daily | label/route/summarize; human owns decisions |

## Multi-loop priority order

When several loops could run, sequence them: **CI Sweeper → PR Babysitter → Dependency Sweeper →
Post-Merge / Changelog Drafter (off-peak) → Daily Triage.** Higher-urgency, blocking work first.

## Safety & gates (the part that keeps it sane)

- **Verifier before action** — no L2+ change is proposed until an automated check (build, tests,
  lint) passes in the worktree. A loop that can't verify can only be L1.
- **No auto-merge on main** except trivial allowlisted dependency patches (allowlist + verifier).
- **Denylist** — protect fragile/showcase files, core primitives, and the audit/scoring logic from
  unattended change; route those to humans.
- **Kill switch** — a `loop-pause-all` label or a flag in `STATE.md` halts every loop at once. Make
  sure one exists before going unattended.
- **Budget & observability** — cap tokens per loop in `loop-budget.md`; append every run to
  `loop-run-log.md` so cost and behavior are auditable. Silent loops are dangerous loops.

## When setting one up

1. Name the goal and the done-condition. 2. Pick the lowest autonomy that delivers value (usually
L1). 3. Define the trigger + cadence (cost-aware). 4. Write/point at the verifier. 5. Decide the
gates (allowlist, denylist, kill switch). 6. Wire STATE.md + run-log. 7. Run it report-only, watch
the log, and only raise autonomy once it's earned trust.

> Upstream reference: github.com/cobusgreyling/loop-engineering (methodology + `loop-init` /
> `loop-cost` / `loop-audit` CLIs). This skill captures the methodology; the npm CLIs are optional
> and, being third-party, should be installed/run by the user, not auto-invoked.
