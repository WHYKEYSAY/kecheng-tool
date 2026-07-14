---
name: librarian
description: Maintains a shared personal/team "Library" of assets and knowledge notes — "triage inbox", "file this into the Library", "add this to the Library", "update library catalog/index", or periodically tidy. Classifies items, writes sidecar metadata, moves them into the right place, keeps a catalog + index in sync so a "save useful things" folder doesn't become a dump.
---

# librarian — keeps a Library usable

Maintains a `Library/` folder (path is whatever your synced/versioned storage root is). **Always read the Library's own schema file first** (e.g. `_index/SCHEMA.md`) — that's the source of truth for structure, metadata fields, type vocabulary, and naming rules. This skill executes the schema; it doesn't invent its own.

**Note:** this skill describes a pattern and references a handful of small companion scripts (a thumbnail generator, an index builder) that you'll need to write for your own Library — they aren't included here. Treat the steps below as the workflow to implement, not a drop-in tool.

## When to run
"Triage inbox", "file X into the Library", "add X to the Library", "update catalog/index", or a periodic tidy.

## Triage loop (per item in `_inbox/`)
1. **Inspect** — open the file/folder/link. Decide what it *is*.
2. **Classify** — pick a `type` from the schema and its destination, e.g.:
   - reusable creative material → `assets/<category>/...`
   - domain reference/read → `knowledge/<domain>/...` (make a new domain folder if needed)
3. **Rename** per your schema's naming convention (kebab-case is a reasonable default).
4. **Make a folder, not a flat file** — write a short note, a same-named companion `<entry-name>.md`. If the item's primary file already has a fixed frontmatter shape owned by another system (e.g. a skill's own `SKILL.md`), don't restructure it — add a sibling `_library.md` note instead. **Tag generously** so a tag-aware note-taking tool (Obsidian etc.) picks it up; preserve provenance (record `license: unknown` rather than guessing).
5. **Generate a thumbnail** — every entry gets a square cover image. Prefer a **real cover** in this order: (a) if the material has a real image (screenshot/texture/render), use it directly; (b) for a skill/UI/design entry, generate a small self-contained HTML that visually *demonstrates* the entry, then render it with a headless browser to a PNG; (c) only fall back to a generated placeholder (a coded background color + simple glyph) if no real cover and no headless browser is available — check for one (`which chromium chrome google-chrome`) rather than assuming.
6. **Assign a short code** per category (append-only — never renumber existing codes; find the current max and +1). Codes are how humans/agents refer to entries later (e.g. "use U11").
7. **Rebuild the index/catalog** after changes (whatever script generates your Library's browsable index).

## Self-heal covers
On every tidy pass (not just new adds), check for entries still sitting on a placeholder cover and proactively generate a real one for them — don't wait to be asked, and don't leave the sweep half-done.

## Catalog entry shape (example)
```json
{ "id": "ui-ux/palettes/rose-gold-ocean", "path": "assets/ui-ux/palettes/rose-gold-ocean.json", "type": "palette", "title": "Rose-gold on ocean", "tags": ["color","dark","warm"], "source": "original", "license": "CC0", "added": "2026-06-23", "owner": "your-name", "summary": "Warm rose-gold accent over a navy ocean base." }
```

## Guardrails
- **Do NOT auto-rewrite hand-written people/about-us content** — those are profiles, not assets.
- Don't move or re-tag already well-placed, sidecar'd entries unless asked.
- Never invent a `source`/`license` — record `unknown`.
- Don't touch credentials or private data; if an inbox item looks like a secret, leave it and flag it.
- Report a short summary at the end: what was filed, where, anything that needs a human decision.

## Output
A short report: `N items filed` → bullet list of `item → destination (type, tags)`, plus anything left in `_inbox/` that needs a human call.
