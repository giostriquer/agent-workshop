# doc-to-html

## Origin

A long research session ended the way many do: a markdown findings document and the request "make this a page I can actually read." The page got built ad hoc — and then rebuilt, because the first pass made every classic mistake: serif body text that read muddy on the dark canvas, gray-on-gray metadata nobody could read, a rainbow of colored sub-boxes fighting for attention, and links that had never been checked. Later edits made it worse: an attempted restyle toward a calmer aesthetic was done incrementally on markup built for the louder one, and a mid-document section insertion silently broke the TOC, the element ids, and the keyboard-nav order.

By the end, the conventions that survived were worth keeping and the editing mistakes were worth forbidding. `doc-to-html` freezes both.

A second round of lived-in use — rendering several real reports, including a multi-section QA-findings deck — surfaced the deeper lesson: the skill's own defaults were the *wrong starting point* when a report already lived in the repo. Matching that sibling artifact, not the skill's defaults, is now the first move; the defaults are the no-sibling fallback. Findings cards gained a required evidence-and-fix structure, findings sort by severity, and a handful of concrete render bugs (raw scrollbars, a number badge misaligned from its heading, a cost pill that floated inconsistently) got pinned shut.

## Problem

Failure families recur when a session builds a report page without the distilled conventions:

1. **Readability on dark canvases.** Serif on dark reads muddy; dim gray text on a dark background is the #1 readability killer; per-block colored boxes and left-border stripes turn a calm report into noise. Each is rediscovered by user complaint, one round-trip at a time.
2. **Structure drift under edits.** Numbered cards, TOC entries, element ids, cross-references, and the keyboard-nav order array are five copies of the same ordering. Insert or move one section and some subset silently desyncs — and nobody re-checks.
3. **Wrong edit strategy.** Restyling markup incrementally toward a *different design direction* compounds into a mess; and a single "I don't like it" gets answered with a whole-design swing when one knob (contrast, density, hierarchy) was the actual complaint.
4. **Defaults applied over an existing house style.** A repo with a sibling `.html` report already has an aesthetic. Reaching for the skill's own defaults first produces a wrong-look first pass that is thrown away whole and rewritten against the sibling — the most expensive single mistake of the second round.
5. **Findings cards that say nothing.** A card that is only label → headline → body reads as "fancy but empty." Audit/QA findings need the claim's concrete evidence (`file:line`, a live result, an appendix cite) and an action with a cost — carried by structure, not left to prose discipline. And findings shown in arrival order, not severity order, bury the worst item mid-page.

## Solution shape

A rendering contract plus an editing discipline. **Step 0 comes before everything: match the repo's existing house style if one is found** (read a sibling report's `<style>` and component vocabulary; the defaults are only the no-sibling fallback). The page architecture is fixed (single self-contained file, sticky TOC with keyboard nav, tables over prose walls, verified-links-only with inline result annotations, evidence appendix, styled scrollbars, print stylesheet). The fallback design system — dark blue-gray canvas, bright sans-serif body, the rich card-and-chip vocabulary adopters expect (`.sec-num`, `.hero`/`.stat-grid`, `.card`/`.pid`/`.chip`, `.claim`, `.term`, `.why`, `.fix`/`.cost`, cite-chips) — is framed as **defaults**, adaptable when a document needs a different mood. The process rules are **rigid**: one-pass generation, targeted-edit vs clean-rewrite (a design-direction change always rewrites), one-knob-at-a-time feedback handling, a collision-safe renumbering procedure, and a pre-finish checklist (parse-check, TOC targets, nav-order array, severity order, styled scrollbars, badge/cost-pill alignment, no dropped content).

For findings reports specifically: order findings by severity descending, give each card a required claim → evidence → fix-with-cost structure, group items into prefixed sub-sections when they partition, and offer an optional Method section.

The skill also embeds compact reference markup for the structures sessions kept reinventing — the finding card (id/chip header → claim quote box → evidence → fix + cost pill), the header-row alignment, the styled scrollbar, the terminal block, and the vertical stepper — so future sessions copy rather than improvise.

## Real invocation snippet

> /doc-to-html turn docs/audit-findings.md into a standalone page

One pass, full page, checklist run before handover.

> the page feels too dense

Not a redesign trigger. The skill asks which element fails — contrast, density, or hierarchy — and turns that knob only.

> add a "rollback plan" section between 6 and 7

Renumbering procedure: descending replace-all, then cross-references, TOC, ids, and the keyboard-nav array, verified with a grep.

> order the findings by severity

Sort descending (critical first), then the renumbering procedure so ids run top-down and every cross-ref/TOC/nav entry follows.

## Pitfalls observed

- **Defaults over an existing house style.** Reaching for the skill's own look when the repo already has a report aesthetic — the first pass is wrong-aesthetic and gets thrown away. Glob for a sibling `.html` and match it *before* generating.
- **Findings cards that are fancy but empty.** A card without a concrete evidence line and an action reads as decoration. Make the structure force claim → evidence (`file:line` / live result / appendix cite) → fix + cost.
- **Raw OS scrollbars.** Overflowing terminal blocks and wide tables show the unstyled system scrollbar against a dark page — jarring. Theme every scroll container.
- **Number badge misaligned from its heading.** `align-items:baseline` floats a small mono badge high or low next to a large heading; use `align-items:center` when the sizes differ.
- **Inconsistent cost-pill placement.** A cost pill that lands at the end of whichever sentence is last varies card to card; pin it to one place (the Fix header).
- **Incremental restyling toward a new direction.** The single most expensive mistake. Markup built for one aesthetic resists another; each patch adds special cases. Direction change = clean rewrite, every time.
- **Whole-design swings from vague dislike.** "Looks off" answered with a new palette, new layout, new typography — destroying the parts that worked. Ask for the failing element first.
- **Partial renumbering.** Renumbering the headings but not the ids, or the ids but not the keyboard array. The grep verification step exists because "I think I got them all" was wrong repeatedly.
- **Unverified links.** A polished page full of links nobody fetched reads as authoritative and isn't. "Verified links only" means *don't ship unverified links* — enrichment links are optional, but whatever ships is fetched. Some canonical-looking doc URLs are JS-rendered and 404 to a server-side fetch; confirm before relying.
- **Evidence inline.** Pasting raw terminal output and long quotes into the body to "show the work" — the body becomes unreadable. Appendix, cited from the body.

## Adaptation notes

- Step 0 has primacy: when a repo has a house style, *that* is the design system and the defaults below it are moot. The defaults matter only in a greenfield repo.
- The design system is the adaptable half: a light theme, a different accent family, or a denser layout are legitimate per-document choices. Keep the readability floors (bright text, readable chips, styled scrollbars) even when the mood changes.
- The process rules are the portable half — they apply unchanged to any theme, including light ones.
- The reference markup is a starting point, not a component library; adapt class names and tokens to taste, keep the shapes. It uses generic placeholders (`F-1`, `AUTH-1`, neutral finding text) on purpose — the skill is system-agnostic, so no real product, ticket, or path names belong in it.
- Pairs naturally with `visual-advisor` when the page's look needs art-direction judgment beyond the defaults — `doc-to-html` governs structure and process, not taste exploration.
