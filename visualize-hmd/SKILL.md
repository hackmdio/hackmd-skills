---
name: visualize-hmd
description: >-
  Generate an HTML/CSS visualization of the currently discussed plan, topic,
  architecture decisions, or trade-offs, then publish it to HackMD (My workspace).
  Runs a build step that converts standalone HTML to HackMD-compatible markup
  before publishing via CLI, API, or MCP.
  Use when the user says "visualize", "visualize with HTML/CSS", "show in HTML",
  "show me with a webpage", or any equivalent request to render a plan visually
  and publish to HackMD.
---

# Visualize — HackMD

Turns conversation context into HTML/CSS, builds HackMD-safe markup, publishes to HackMD.

**Scope:** User wants a **generated visualization** from the discussion. If they already have a file to upload, use `push-to-hackmd` instead.

**Paths:** In a monorepo checkout, set `SKILL_DIR` to this folder (e.g. `hackmd-skills/visualize-hmd`). Scripts live under `$SKILL_DIR/scripts/`.

---

## For agents (workflow)

### Step 1 — Analyze context

Identify: architecture trade-offs, phased plan, decision crux, or topic overview. Extract the **crux** (hardest tension) — it gets the most visual weight.

### Step 2 — Layout selection (decision tree)

```
Exactly 2 competing options with clear pros/cons?
  → Trade-off map
4–6 sequential phases with distinct boundaries?
  → Phase runway
3+ independent decisions, no natural order?
  → Decision grid
Otherwise / mixed / overview only?
  → Brief (hero + sections); may embed another pattern in one section
Multiple patterns apply?
  → Pick the one that makes the crux most visible
```

| Pattern | When to use |
|---------|-------------|
| **Trade-off map** | Two lanes + divider |
| **Phase runway** | 4–6 cards in a row |
| **Decision grid** | 2×N or 3×N cards |
| **Brief** | General overview |
| **Facet cards** | "Pick your role / period" filter without JavaScript |
| **Row timeline bar** | When each item in a list happens (mini Gantt) |

Use HTML fragments and tokens from [reference.md](reference.md) — do not invent new CSS class names.

### Step 3 — Write standalone HTML

Write `/tmp/viz.html` with `<!DOCTYPE html>`, `<html>`, `<head>` (Google Fonts `<link>`), `<body>`. No JavaScript. Avoid `<main>` (build script rewrites to `<div>`).

### Step 4 — Build HackMD output

```bash
SKILL_DIR="<path-to>/visualize-hmd"
python3 "$SKILL_DIR/scripts/to-hackmd.py" --strict /tmp/viz.html /tmp/viz-hackmd.html
```

Check `$?` — non-zero means conversion failed; do not publish.

**One-shot create (optional):**

```bash
VIZ_TITLE="Visualization — <topic>" "$SKILL_DIR/scripts/publish-viz.sh" /tmp/viz.html /tmp/viz-hackmd.html
```

### Step 5 — Publish channel selection

```
hackmd-cli in PATH and hackmd-cli whoami succeeds?
  yes → CLI (preferred)
else HACKMD_API_TOKEN set?
  yes → REST API (see push-to-hackmd / shared/references/api.md)
else HackMD MCP available?
  yes → MCP create_note
else → stop; instruct user to hackmd-cli login or set token
```

**Create vs update:**

| User intent | Action |
|-------------|--------|
| "visualize" (default) | **Create** new note |
| "update" / provides note URL or id | Resolve id → export baseline → replace body via [../../shared/scripts/safe-sync.sh](../../shared/scripts/safe-sync.sh) |
| Same title already exists | Warn; ask before overwrite |

For updates, follow [../../shared/README.md](../../shared/README.md).

### Step 6 — Custom CSS + size

- Append or confirm reminder: `<!-- Enable Custom CSS preview: paintbrush → Custom CSS -->`
- Tell the user to enable **Custom CSS** in the toolbar (required for `<style>` to apply).
- Keep each note under about **100 KB**. HackMD rejects updates to larger notes. If the content is bigger, shrink it (see [reference.md → Shrinking a large note](reference.md#shrinking-a-large-note)) or split it into embedded notes (Step 7).

### Step 7 — Share one style across notes with embedded notes

HackMD can embed one note inside another with `{%hackmd <noteId> %}`. Use this to:

- **Share one style across the account.** Put the `<style>` block in one style note. Every visualization embeds it, so all of them look the same, and one edit restyles them all.
- **Reuse a block.** Put a card or section in its own note, then embed it in every note that needs it.
- **Keep notes small.** Split a large visualization into several notes.

```
Style note (×1)    = <style>…</style> only
Module note (×N)   = {%hackmd <styleId> %} + one block (for example one <details> card)
Host note          = {%hackmd <styleId> %} + hero + headings + {%hackmd <moduleId> %} lines
```

1. Look for an existing style note in the user's account (for example a note titled `Style — visualize-hmd`). Reuse it if it exists. Create it only if it does not.
2. In the style note, put only the `<style>` block. Write any explanation as an HTML comment, because visible text shows up in every note that embeds it.
3. Create one module note per block. Start each module with `{%hackmd <styleId> %}`, so it looks right on its own and inside any other note.
4. Write the host note by hand. Put each embed on its own line, with a blank line before and after it. Do not run `to-hackmd.py` on the host note, because it removes those blank lines.
5. Give the style note and every module the same read permission as the notes that embed them. If the host is public, make them public too. Readers who cannot open a module see that part of the host as empty.
6. Keep a list of the note ids, so the next update changes the existing notes instead of creating new ones.

Embedded notes render inline, not in a frame. The host's CSS applies to them, `<details>` works inside them, and links to `id` anchors inside them work from the host. To lay modules out in a grid, see [reference.md → Embedded notes](reference.md#embedded-notes).

### Failure modes

| Failure | Recovery |
|---------|----------|
| `to-hackmd.py --strict` fails | Fix HTML (blank lines in body, `<main>`, unscoped `body{}`); rebuild |
| Publish fails | Do not claim success; report CLI/API error |
| User sees unstyled note | Custom CSS not enabled — repeat step 6 |
| Update fails because the note is too large | Split it into embedded notes (Step 7) |
| Text from the style note shows up in every note | Move that text into an HTML comment in the style note |
| Part of a public note is empty for readers | Make the embedded note public too (Step 7, item 5) |

---

## For manual users

See [README.md](README.md) and [reference.md](reference.md) for design tokens, patterns, and CLI examples.

---

## Why blank lines break HackMD rendering

HackMD uses markdown-it (CommonMark). Type 6 HTML blocks (`<div>`, etc.) **end at a blank line**. The build script removes blank lines inside the body and strips 4-space indentation so content is not parsed as code blocks.

---

## Antipatterns

- Decorative sections that repeat card content
- More than 3 accent colors
- Omitting the crux when a hard trade-off exists
- JavaScript (stripped by HackMD)
- Copying the full `<style>` block into every note — embed the shared style note instead

---

## Related skills

- [../push-to-hackmd/SKILL.md](../push-to-hackmd/SKILL.md) — generic publish / backup
- [../agentic-work-log/SKILL.md](../agentic-work-log/SKILL.md) — link new viz URL in work log callout when useful
- [../shared/README.md](../shared/README.md) — safe update contract

## Design system

See [reference.md](reference.md).
