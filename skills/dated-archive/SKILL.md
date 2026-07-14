---
name: dated-archive
description: File a generated artifact (report, research, deep-dive, curated material) into a shared storage root using a dated nested-folder convention — <AREA>/<YYYY>/<MM>/<DD>/<slug>/ holding index.html + index.md + an optional social-card carousel rendered to PNGs, plus an _index.md log. Use whenever saving a substantial generated output, or when the user says "file this" / "archive this" / wants generated reports organized consistently.
---

# Dated-archive convention

When generating a substantial artifact to save, **never dump loose files at an area root** — file it like this. Adapt `<STORAGE_ROOT>` to wherever your shared storage/vault actually lives (a synced folder, a repo, a knowledge-base directory).

## Path
```
<STORAGE_ROOT>/<AREA>/<YYYY>/<MM>/<DD>/<slug>/
```
- **`<AREA>`** by content type: e.g. `knowledge/finance`, `knowledge/art`, or a top folder like `research` / `materials`. Reuse an existing folder if one fits — if you run multiple recurring content pipelines (e.g. a daily finance digest and a daily design digest), give each its own `<AREA>` subtree so they don't collide.
- **`<YYYY>/<MM>/<DD>`** = today, zero-padded (e.g. `2026/06/26`).
- **`<slug>`** = short kebab-case from the title (e.g. `micron-memory-supercycle`).

## Files inside the `<slug>/` folder
1. **`index.html`** — the rich, polished report. Self-contained single file, `prefers-reduced-motion` aware, sources as clickable links, disclaimer footer where relevant. If you maintain a library of design templates, pick a different one each time rather than always defaulting to the same look.
2. **`index.md`** — the same content as clean Markdown (for reading/archiving), with sources + disclaimer.
3. **`cards.html`** (optional, if you post to social/short-form platforms) — a carousel: 5-6 `<section class="card">`, each sized for the target platform's aspect ratio (e.g. `1080x1350` for a 4:5 portrait post). Card 1 = hook/cover; middle cards = one key point each; last = takeaway + disclaimer. Give it a query-param isolation script so each card can be screenshotted individually:
   ```html
   <script>const c=new URLSearchParams(location.search).get('card');if(c){const i=+c-1;document.querySelectorAll('.card').forEach((el,k)=>{el.style.display=(k===i?'flex':'none')})}</script>
   ```
4. **`card-1.png … card-N.png`** — render the carousel to ready-to-post images via a headless-browser screenshot script of your own (Windows Chrome headless, or `chromium --headless=new --screenshot=...`), one image per card.

## Index log
Append one line to **`<STORAGE_ROOT>/<AREA>/_index.md`**:
```
- <YYYY-MM-DD> · <topic/title> · <YYYY>/<MM>/<DD>/<slug>/
```

## Notes
- **Bilingual (for posting)**: when the artifact is meant to be posted in more than one language/market, produce a `<slug>/<lang>/` subfolder per language, each its own `index.html` + `index.md` + `cards.html` + `card-*.png`. Put shared assets (a downloaded source image, etc.) at the `<slug>/` root and reference them relatively from each language folder.
- **Asset feedback loop (optional)**: if the artifact reuses or produces reusable raw material (an image, a UI pattern, a palette), also curate that piece back into a separate assets library, distinct from the finished-output archive above — assets = reusable source material, knowledge/output = finished pieces.
- This convention is for **output artifacts** you generate — it's separate from wherever your agent's own instruction/skill files live (e.g. Claude Code skills live at `~/.claude/skills/`).
- Keep it tasteful and cited; for finance/investment content always add a "not personalized advice" disclaimer.
