---
name: doc-to-html
description: Use when turning a markdown report, audit, review, or research/findings document into a polished standalone dark-themed HTML page, or when revising such a page — content tweaks, inserting/moving numbered sections, design-direction changes, or "this looks noisy / unreadable / ugly" feedback.
---

# Doc to HTML

## Purpose

Render a markdown document (report, audit, review, research findings) as a single self-contained HTML page that reads calmly on a dark screen, navigates well, and prints clean — then govern how that page is edited afterward.

Two stances, deliberately different: the **design system is a set of battle-tested defaults** — adapt the mood when the document calls for it. The **process rules are rigid** — each one exists because its absence failed in real use.

## Page architecture

Every page gets:

- **Single self-contained file.** Inline CSS and JS, no external assets, no build step. The page must open from disk.
- **Sticky TOC sidebar** with an active-item highlight, plus keyboard navigation (`j`/`k` or arrow keys) driven by one explicit array of section ids in document order.
- **Tables over walls.** Short enumerable facts go in tables; explanation lives in the surrounding prose, not in the cells. Never a wall of paragraphs doing a table's job.
- **Verified links only.** Every external link on the page was actually fetched and checked before shipping. Annotate the result inline (small green/red run next to the link). An unverified link does not ship.
- **Evidence appendix.** Raw quotes, terminal output, and source excerpts live in an appendix at the end; the body cites them. The body stays readable without dropping the proof.
- **Print media query.** White background, dark text, hide the nav and keyboard hints.

## Design system defaults (dark, calm, structured)

- Dark blue-gray canvas; **sans-serif** body (serif reads muddy on dark screens) at ≥15px with generous line-height. Text must be bright (#d0d8e0-ish) — gray-on-dark is the #1 readability killer; when in doubt, brighten.
- Cards as subtle panels (1px border, radius, slightly lighter than canvas). NO colored left-border stripes, NO colored sub-boxes per block — section labels are quiet small-caps mono runs; metadata is a plain line with at most TWO small badges.
- One accent color family used sparingly (headline callout rule, active TOC item) plus semantic green/red ONLY inside terminal blocks and link-result annotations.
- Inline code chips must be readable: ~0.9em, near-white text on a clearly lighter chip.
- Differentiate special sections (caveats, "maybe" items) with a subtle background or dashed border — not louder colors.

## Process rules (rigid)

- **One pass.** Generate the full HTML in one pass from the markdown.
- **Targeted edit vs clean rewrite.** Content tweaks are targeted edits. A change of design DIRECTION is always a full clean rewrite — incrementally restyling markup built for a different aesthetic compounds into a mess.
- **One knob at a time.** If the user dislikes the result, ask which specific element fails (contrast, density, hierarchy) and turn that one knob; don't swing the whole design.
- **Renumbering procedure.** If sections/cards are numbered and an insertion or move forces renumbering: renumber via descending replace-all or a temp placeholder (avoid collisions), then update every cross-reference, TOC entry, element id, and the keyboard-nav order array, and verify with a grep that ids are sequential and references resolve.

## Pre-finish checklist

1. Parse-check the HTML (balanced tags).
2. Verify every TOC target id exists.
3. Verify the keyboard-nav order array matches document order.
4. Confirm no markdown content was dropped — spot-check section count and headline statements.

## Reference markup

Card (label → headline → metadata → body). Headlines state the finding, not the topic:

```html
<section class="card" id="s04">
  <p class="label">04 · FINDINGS</p>
  <h2>Headline statement of what was found</h2>
  <p class="meta">source-name · 2026-06-11 <span class="badge ok">verified</span></p>
  <p>Body…</p>
</section>
```

```css
.card  { background:#161d29; border:1px solid #28344a; border-radius:10px; padding:20px 24px; }
.card.maybe { border-style:dashed; background:#141a24; }   /* caveat / "maybe" variant */
.label { font:600 12px/1 ui-monospace,monospace; letter-spacing:.14em; color:#7d8fa8; }
.meta  { color:#94a3b8; font-size:14px; }
.badge { font-size:12px; padding:1px 8px; border:1px solid #3b4a63; border-radius:999px; }
```

Vertical stepper (ordered process; connector line through the dots):

```html
<ol class="stepper">
  <li><span class="dot"></span><div><h3>Step title</h3><p>What happens.</p></div></li>
  <li><span class="dot"></span><div><h3>Next step</h3><p>…</p></div></li>
</ol>
```

```css
.stepper { list-style:none; margin:0; padding:0; }
.stepper li { position:relative; display:flex; gap:16px; padding-bottom:24px; }
.stepper li::before { content:""; position:absolute; left:7px; top:18px; bottom:0; width:2px; background:#28344a; }
.stepper li:last-child::before { display:none; }
.dot { flex:none; width:16px; height:16px; margin-top:4px; border-radius:50%; border:2px solid #5b8dd6; background:#0f1520; }
```

## Suggested invocation

- Turn `report.md` into a standalone HTML page.
- The page feels noisy / unreadable — fix it. (→ ask which knob fails: contrast, density, or hierarchy)
- Insert a new section between 4 and 5. (→ renumbering procedure, then the checklist)
- Make it feel like a printed zine instead. (→ design-direction change: full clean rewrite)
