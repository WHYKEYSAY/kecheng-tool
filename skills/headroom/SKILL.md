---
name: headroom
description: Token-compression tool for LLM calls and agents — compress tool outputs, logs, files, RAG chunks, and conversation history BEFORE they reach the model (60–95% fewer tokens, same answers). Use when an agent/proxy/session is burning tokens on big tool outputs or long context, or to cut API cost. This is an install + usage reference (the tool itself is external; install it yourself).
metadata:
  type: skill
  tags: [tokens, compression, cost, llm, agent, proxy, mcp, infra]
  source: github.com/headroomlabs-ai/headroom
  summary: Reference for headroom-ai — wrap/proxy/MCP token compression to cut LLM tokens 60–95%.
---

# headroom — cut LLM tokens 60–95%

`headroom-ai` (github.com/headroomlabs-ai/headroom, Python 3.10+) compresses **tool outputs, logs, files, RAG chunks, and conversation history before they reach the model** — 60–95% fewer tokens, same answers. Ships as a **library, proxy, MCP server, or agent-wrap**.

## Install (external tool, not bundled here)
```bash
uv tool install --python python3.13 "headroom-ai[all]"      # preferred
# or:  pip install "headroom-ai[all]"      # Python 3.10+
# or:  docker pull ghcr.io/chopratejas/headroom:latest
```
Granular extras instead of `[all]`: `[proxy] [mcp] [ml] [code] [memory] [relevance] [image] [agno] [langchain]`.

## Use it
- **Wrap an agent, zero code change:** `headroom wrap claude`  (also `codex` / `cursor` / `aider` / `copilot` / `opencode`)
- **Proxy in front of any LLM (any language):** `headroom proxy --port 8787` → point your client's base URL at it
- **MCP server for any MCP client:** `headroom mcp install`
- **Inline (Python):** `from headroom import compress; compress(messages, model=...)`
- **Check routing / health:** `headroom doctor`   · **analyze savings from logs:** `headroom perf`
- Other commands (v0.27): `learn` (mine past tool-call failures), `evals`, `unwrap` (undo a wrap)

## When to reach for it
- An agent/session is burning tokens on **huge tool outputs, logs, or long context**.
- You're running a local model behind a proxy and want to cut the tokens hitting it, or fronting a paid API (Claude/OpenAI/etc.) to cut cost.
- Want **cross-agent shared memory** + `headroom learn` (mines failed sessions → writes corrections to `CLAUDE.md` / `AGENTS.md`).

## Note
- The actual tool is NOT vendored in this skill folder (external code → install it yourself per above). This card just tells you/agents when and how to use it.
- Sibling **headroom-desktop** (gglucass/headroom-desktop) is a **macOS menu-bar app** (routes Claude Code/Codex; edits `~/.claude/settings.json`). It does **not** run on Windows/WSL/Linux — only relevant on a Mac.
