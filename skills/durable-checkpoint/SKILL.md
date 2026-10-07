---
name: durable-checkpoint
description: Record a session's durable reasoning into an external brain - a synced or version-controlled directory holding an append-only archive of checkpoints - so decisions, dead ends and gotchas survive past the session that produced them. Use when the user says "checkpoint", "write this to the brain", or asks how to give an agent memory across machines, how to stop a new session relitigating a settled decision, or whether to recommend the practice to a team. For a transient "here is what to do next" handoff inside one workspace, use the kiro-session-handoff skill instead.
license: MIT
metadata:
  version: "2.1.0"
  short_description: "Archive a session's durable reasoning into an external brain that later sessions load unconditionally."
  roles:
    - developer
    - solution-architect
runtimes:
  - kiro
---

# Durable checkpoint - flush what matters into an external brain

A pattern for giving an agent memory across sessions and machines without
relying on any one context window. Point it at your own brain location: a git
repo, a synced folder, or any durable storage the agent can write to and future
sessions can read from.

## Which skill, and when

This space is crowded and the skills are complementary, not interchangeable.
Pick by what you need to survive:

| Need | Skill |
|---|---|
| "Here is exactly what to do next" for the next session in this workspace, then throw it away | **kiro-session-handoff** |
| Per-epic or per-story state, pulled into context only while you work that topic | **steering-doc-manager** |
| Per-project facts and lessons, deduplicated | **wrap-up** |
| Reasoning, dead ends and decisions that must outlive the task, discoverable months later, across machines | **this skill** |

The distinction that matters: a handoff is an instruction that becomes obsolete
once executed, and is deliberately deleted. A checkpoint is a record of *why*
and is deliberately kept. If deleting the file after the next session would be
correct, you want a handoff, not a checkpoint.

## What to capture (durable only)

Checkpoint what a fresh session would need and cannot derive from the repo or
git history:

- **Decisions and their why** - not what changed, the reasoning. "We kept the
  on-disk extension as .md even though the spec says .txt, because two
  downstream consumers glob *.md" is worth more than the diff that did it.
- **Dead ends** - what was tried and rejected, and why. These produce no commit,
  so git cannot hold them, and the next session will walk the same path.
- **Current state and open threads** - what is in flight, what is blocked and on
  whom.
- **Gotchas** - a pitfall, a non-obvious constraint, a "don't do X".
- **Pointers** to where the real artifacts live, not their contents.

Do not checkpoint what is already in code, git, or project instructions;
secrets; or conversation trivia. A lasting fact about the user or their
preferences belongs in a long-lived profile file, not a checkpoint. Session
state and threads belong here.

## How to write it

1. Draft a tight body in markdown. A few paragraphs or bullets; link related
   notes by name.
2. Pick a short-kebab slug and a tag: `active` (ongoing), `done` (closed),
   `deadend` (tried, no), `conjectured`, `validated`.
3. Write it through a gated writer script. Never hand-edit the brain files from
   inside a live session - a script keeps the format consistent and lets you
   enforce append-only history:

       printf '%s\n' "<body>" | bash "<BRAIN_ROOT>/scripts/checkpoint.sh" <slug> <tag>

   A minimal writer stamps the body into `checkpoints/<date>-<slug>.md`,
   prepends one line to `ledger/LEDGER.md`, and regenerates a short `NOW.md`
   holding only the open threads.
4. If the brain is version-controlled, commit it with the user's identity, not
   the agent's.
5. If the writer only touches a primary copy, sync any mirror afterwards. A
   script that writes one of two copies will silently drift.

## Make it load, do not rely on being read

This is the part the pattern usually gets wrong, so rank the options by whether
they are enforced rather than by convenience:

| Mechanism | Enforced? |
|---|---|
| Content injected by an always-included steering/context file | Yes |
| A `SessionStart` / `agentSpawn` hook that prints it | Yes |
| A steering file that *tells* the agent to go read `NOW.md` | No |
| Relying on the agent to remember to read it | No |

The bottom two fail. Observed directly: a session that worked on the exact
subject area a steering file named, for hours, and never opened `NOW.md` once -
while two other always-included steering files sat in its context the entire
time. A pointer is not a mechanism.

So have the writer script emit the enforced copy as a side effect. After
regenerating `NOW.md`, write a steering file whose frontmatter marks it
always-included and whose body is the open-thread headlines:

    STEERING_FILE="${BRAIN_STEERING_FILE:-$HOME/.kiro/steering/brain-now.md}"

### `inclusion: always` is a tradeoff, not a free win

It costs tokens on every single session, forever. The opposite choice is
defensible and `steering-doc-manager` makes it deliberately: `inclusion:
manual`, pulled in with `/context add` only while you are working that topic,
so context cost tracks active work rather than the number of topics tracked.

The split that reconciles them is size and universality:

| Content | Inclusion |
|---|---|
| A dozen one-line headlines, relevant to any session | `always` - cheap, and the whole point is that nobody has to remember |
| A per-epic document, relevant to one topic | `manual` - loading all of them would scale with topics, not with work |

If the mirror is creeping past a few KB, that is the signal it has stopped
being headlines. Shrink it rather than accepting the cost.

Three further constraints on the mirror, learned the hard way:

- **Keep it small.** Headlines only, capped count, truncated summaries, and a
  pointer to `checkpoints/` for the reasoning. Carrying the reasoning here is
  how a 2 KB file becomes 20 KB.
- **Normalise it.** Summaries copied from older checkpoints carry em-dashes and
  smart quotes. Generated files should be plain ASCII rather than inheriting
  whatever an old entry happened to contain.
- **Degrade safely.** If the steering directory is missing, or the extraction
  fails, warn that `NOW.md` is still correct but a new session will not be told,
  and carry on. The mirror must never become the only copy.

## Watch for decay

Two failure modes show up once there are a few dozen checkpoints:

- **Tag drift.** `active` accumulates because closing a thread needs a new
  checkpoint and nobody writes one. If more than half the entries are `active`
  while several are plainly delivered, the board has stopped meaning anything.
  Add a close path to the writer.
- **Stale headlines.** An open thread older than a month is either not open or
  not tracked. Check the age distribution occasionally, not just the count.

## Before recommending this to a team

Recommend the habit, not the artifact, and split by audience:

| What | Where | Why |
|---|---|---|
| Decisions and traps about code | In the repo, beside the code | Versioned and reviewed with the thing it describes; read without anyone opting in |
| Process and tool lore | A skill | Loads automatically for everyone |
| Who is blocked on what | The team's tracker | Others can see it; a brain entry is a shadow record |
| "Where I left off" | A personal brain | The only thing the others do not cover |

A personal brain is single-author. Five people means five wordings of the same
decision and no way to know which to trust. Present it as a personal notebook,
never as the team's record.
