# kecheng-tool

A collection of agent "skills" — reusable, self-contained instruction files that teach a coding/writing agent a specific workflow (writing-editing patterns, token-compression usage, a filing convention, a personal-memory pattern, an automation-loop design guide, a personal knowledge-library curator, a skill-update watcher).

Each skill is a single Markdown file (occasionally with a small companion script) written as a **plain instruction document**. There's nothing Claude-Code-specific baked into the *content* — the YAML frontmatter at the top of each `SKILL.md` is metadata (name/description), not executable code, so it's harmless to any tool that doesn't understand it.

## Skills

| Skill | What it does |
|---|---|
| [`humanizer`](skills/humanizer/SKILL.md) | Detects and removes signs of AI-generated writing; adds the positive qualities of genuinely human writing. MIT-licensed. |
| [`headroom`](skills/headroom/SKILL.md) | Reference for using the external `headroom-ai` token-compression tool (proxy/MCP/wrap) to cut LLM token cost 60-95%. |
| [`dated-archive`](skills/dated-archive/SKILL.md) | A dated nested-folder convention for filing generated reports/artifacts consistently instead of dumping loose files. |
| [`durable-checkpoint`](skills/durable-checkpoint/SKILL.md) | An append-only archive of session reasoning in an external "brain" folder, plus the writer script and the always-included mirror that makes a new session actually load it. |
| [`loop-engineering`](skills/loop-engineering/SKILL.md) | Design and operate autonomous, recurring agent loops (scheduled triage, PR babysitting, CI sweeps) instead of one-off prompts. Distilled from [cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering). |
| [`librarian`](skills/librarian/SKILL.md) | Pattern for maintaining a personal/team knowledge-and-assets library: triage an inbox, classify, tag, thumbnail, keep a catalog in sync. References small companion scripts you'll write for your own setup. |
| [`skill-upstream-sync`](skills/skill-upstream-sync/SKILL.md) | A small script (`scan.sh`) that reports (never auto-applies) which installed skills' upstream repos have moved since you last checked. |

**Not included**: two third-party-licensed skills I use myself (`taste-skill` by Leonxlnx, `ui-ux-pro-max` by nextlevelbuilder) aren't mine to redistribute — go find them at their original sources if you want them.

## Using these with different agents

The content is agent-agnostic; only *where you put the file* and *how it gets loaded* differs.

**Claude Code**: drop a skill folder into `~/.claude/skills/<name>/` (or a project's `.claude/skills/`). Claude Code discovers it automatically and invokes it via the `Skill` tool when relevant, or on an explicit `/<name>` slash command.

**OpenAI Codex CLI**: Codex auto-loads a project-root `AGENTS.md` for persistent instructions. Either paste a skill's body directly into `AGENTS.md`, or add a short pointer line there (e.g. "For writing edits, follow `skills/humanizer/SKILL.md`") and let the agent read the referenced file when relevant.

**Kiro**: Kiro auto-loads persistent project context from `.kiro/steering/*.md`. Copy a skill's body (minus the Claude-Code-specific frontmatter, if you want it clean) into `.kiro/steering/<name>.md` — steering docs are the closest Kiro equivalent to an always-available skill.

**Any other agent**: if it can read a file and follow instructions — as a system prompt, a pinned context file, or a one-off "read this and do X" — it can use these. There's no special runtime or format required.

## License

MIT (see `LICENSE`) for everything under `skills/` except where a skill's own frontmatter says otherwise (`humanizer` already carries its own MIT marker).
