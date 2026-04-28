---
name: capture-knowledge
description: Capture structured knowledge about a code entry point and save it to the knowledge docs. Use when users ask to document, understand, or map code for a module, file, folder, function, or API.
---

# Knowledge Capture Assistant

Build structured understanding of code entry points with an analysis-first workflow.
Output is optimized for AI agent consumption — concise, layered, and context-efficient.

## Hard Rules
- Do not create documentation until the entry point is validated and analysis is complete.
- `dev/{name}.md` MUST be ≤ 250 lines. Move deeper details to `dev/{name}-detail.md`.
- `business/{name}.md` has no line limit — written for human readability, no code, no source refs.
- Reference source files by path + line range instead of embedding code inline (in `dev/` files only).
- Every `dev/{name}.md` starts with an `<!-- AI-CONTEXT: ... -->` comment (2–3 lines max).
- **Always check existing knowledge docs BEFORE reading source files** — reduces redundant token usage.

## Workflow

0. Check Existing Knowledge (FIRST — before any source file reads)
- Read `docs/ai/domain-knowledge/README.md` to get the full index of existing knowledge docs.
- Identify the **domain** of the entry point using the domain mapping table.
- For that domain: read all existing **`dev/{name}.md`** compact files (≤250 lines each, NOT detail files).
- For adjacent domains that likely share data (e.g., FE plugin ↔ BE module): read their `dev/` compact files too.
- Extract from existing files: architecture, key concepts, dependencies, cross-references, known issues.
- **Reuse** this info in the new doc — do NOT re-read source files for facts already captured.
- Note any gaps or inaccuracies found — fix them during this capture session.

1. Gather & Validate
- Confirm entry point (file, folder, function, API), purpose, and desired depth.
- Verify it exists; resolve ambiguity or suggest alternatives if not found.

2. Collect Source Context
- Summarize purpose, exports, key patterns.
- Folders: list structure, highlight key modules.
- Functions/APIs: capture signature, parameters, return values, error handling.

3. Analyze Dependencies
- Build dependency view up to depth 3, track visited nodes to avoid loops.
- Categorize: imports, function calls, services, external packages.
- Exclude external systems or generated code.

4. Synthesize
- Overview (purpose, language, high-level behavior).
- Core logic, execution flow, patterns.
- Error handling, performance, security considerations.
- Improvements or risks discovered during analysis.

5. Create Documentation (Layered Output)
- Normalize name to kebab-case (`calculateTotalPrice` → `calculate-total-price`).
- Identify the **domain** the entry point belongs to (e.g., `catalog-graph`, `catalog`, `report`, `search`, `dashboard`, `common`).
- Create a **3-file structure** (2 audience layers + detail):

### File Structure

```
docs/ai/domain-knowledge/
├── README.md                              # Index (auto-maintained)
├── common/                                # Shared technical refs — no audience split
│   └── knowledge-{name}.md
└── {domain}/
    ├── business/
    │   └── {name}.md                      # PO/BA layer — plain language, no code, no limit
    └── dev/
        ├── {name}.md                      # AI compact ≤ 250 lines
        └── {name}-detail.md               # Full walkthrough — no limit
```

**Domain mapping** (derive from plugin name or feature area):

| Plugin / Area | Domain Folder |
|---------------|---------------|
| `dop-catalog-graph`, `dop-catalog-graph-backend` | `catalog-graph` |
| `dop-catalog`, `dop-catalog-backend`, `dop-catalog-common` | `catalog` |
| `dop-report`, `dop-report-backend`, `dop-report-common` | `report` |
| `dop-search`, `dop-search-backend` | `search` |
| `dop-asset-inventory`, `dop-asset-inventory-backend` | `asset-inventory` |
| `mob-dashboard`, `mob-dashboard-backend`, `mob-dashboard-common` | `dashboard` |
| `dop-home` | `home` |
| `dop-common`, cross-cutting concerns | `common` |
| `packages/app`, `packages/backend` | `platform` |

**`common/` domain rule:** If a topic file (ReGraph, GraphDB, shared API patterns, etc.) will be referenced by **2 or more** domain folders, place it in `docs/ai/domain-knowledge/common/` (no `business/dev/` split). Link to it from each knowledge file that uses it.

> **Existing shared references in `common/`:**
> - `common/knowledge-regraph.md` — ReGraph library (all diagram types in `catalog-graph`)
> - `common/knowledge-graphdb-ontology.md` — GraphDB EDC ontology (all backend queries in `catalog-graph`)

If the domain is unclear, ask the user. If a new domain is needed, create the folder.

After creating files, **update `docs/ai/domain-knowledge/README.md`** with an entry linking to all 3 new files (business, dev, detail).

### Business File (`{domain}/business/{name}.md`) — no line limit
- **Output language: English** — all prose must be written in English regardless of source code language
- **Domain/technical terms:** preserve original German (or other language) terms when they are established domain vocabulary, and add an English annotation in parentheses on first use — e.g. `Fachkompetenz (domain competency)`, `Leistungserbringer (service provider)`. Do not translate terms that have no direct English equivalent or that users know only by their German name.
- Written in plain language for PO / BA / non-tech readers
- Feature description: what it does, why it exists
- Business flow: what happens step by step (no code, no API names)
- Key terminology / domain vocabulary
- Business rules and constraints
- Stakeholders and system integrations (named, not technical endpoints)
- **No source file refs, no code blocks, no technical jargon**

### Dev Compact File (`{domain}/dev/{name}.md`) — ≤ 250 lines
- `<!-- AI-CONTEXT: ... -->` header — use this format:
  ```
  <!-- AI-CONTEXT: {feature} — FE: {fe-path} — BE: {be-path} — READS_FROM: {upstream-doc or data-source} — WRITES_TO: {downstream-doc or ES index} — Tech: {key-tech} -->
  ```
  Include `READS_FROM` / `WRITES_TO` only when relevant.
- **Business Context** (~30 lines) — summary of `business/` file for AI orientation
- **Technical Overview** (~80 lines) — architecture diagram (mermaid), key files, entry points, data flow
- **Key Patterns** (~50 lines) — key concepts table, dependencies table, notable patterns
- **Cross-references** — links to `business/{name}.md`, `dev/{name}-detail.md`, related docs
- Metadata (date, depth, files touched)

### Dev Detail File (`{domain}/dev/{name}-detail.md`) — no line limit
- Full implementation walkthrough (all numbered sections)
- Reference source by path + line range, not inline code
- Visual diagrams (mermaid) for complex flows
- Additional Insights section
- Only embed code when the pattern is non-obvious from the source

## Writing Rules for AI Readability
- **Progressive disclosure**: Put 80% of value in `dev/{name}.md`. Details behind cross-refs.
- **File refs over inline code**: Write `**File:** path/to/file.ts (lines 45–52)` instead of pasting the code.
- **One concept per sentence**: Avoid compound sentences with multiple technical facts.
- **Tables over prose**: Use tables for mappings, dependencies, concept lists.
- **Mermaid over text**: Use diagrams for flows, sequences, and hierarchies.

## Validation
- `dev/{name}.md` is ≤ 250 lines.
- `business/{name}.md` contains no code, no source refs, no technical jargon.
- `dev/{name}.md` starts with `<!-- AI-CONTEXT: ... -->` with `READS_FROM`/`WRITES_TO` if data flows exist.
- All sections (Business Context, Technical Overview, Key Patterns, Cross-refs) present in `dev/{name}.md`.
- No inline code blocks longer than 5 lines (reference the source instead).
- **No content duplicated** from an existing knowledge doc — use cross-reference links instead.
- **Cross-references are bidirectional** — if doc A links to doc B, doc B must also link to doc A.
- Confirm file paths and remind to commit.
