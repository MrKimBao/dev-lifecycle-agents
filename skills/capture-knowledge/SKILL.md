---
name: capture-knowledge
description: Capture structured knowledge about a code entry point and save it to the knowledge docs. Use when users ask to document, understand, or map code for a module, file, folder, function, or API.
---

# Knowledge Capture Assistant

Build structured understanding of code entry points with an analysis-first workflow.
Output is optimized for AI agent consumption — concise, layered, and context-efficient.

## Hard Rules
- Do not create documentation until the entry point is validated and analysis is complete.
- Summary file MUST be under 150 lines. Move details to separate files.
- Reference source files by path + line range instead of embedding code inline.
- Every summary file starts with an `<!-- AI-CONTEXT: ... -->` comment (2–3 lines max).
- **Always check existing knowledge docs BEFORE reading source files** — reduces redundant token usage.

## Workflow

0. Check Existing Knowledge (FIRST — before any source file reads)
- Read `docs/ai/domain-knowledge/README.md` to get the full index of existing knowledge docs.
- Identify the **domain** of the entry point using the domain mapping table.
- For that domain: read all existing **summary files** (`knowledge-*.md`, NOT detail files) — they are <150 lines each.
- For adjacent domains that likely share data (e.g., FE plugin ↔ BE module): read their summary files too.
- Extract from existing summaries: architecture, key concepts, dependencies, cross-references, known issues.
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
- Create a **layered file structure** under `docs/ai/domain-knowledge/{domain}/`:

### File Structure

```
docs/ai/domain-knowledge/
├── README.md                          # Index of all knowledge docs (auto-maintained)
├── {domain}/                          # Domain subfolder (e.g., catalog-graph, catalog, report)
│   ├── knowledge-{name}.md            # Summary (<150 lines)
│   ├── knowledge-{name}-detail.md     # Full implementation details
│   └── knowledge-{name}-{topic}.md    # Standalone reference (if needed)
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

**`common/` domain rule:** If a topic file (ReGraph, GraphDB, shared API patterns, etc.) will be referenced by **2 or more** domain folders, place it in `docs/ai/domain-knowledge/common/` instead of in a specific domain. Link to it from each knowledge file that uses it. Do NOT duplicate the content.

> **Existing shared references in `common/`:**
> - `common/knowledge-regraph.md` — ReGraph library (all diagram types in `catalog-graph`)
> - `common/knowledge-graphdb-ontology.md` — GraphDB EDC ontology (all backend queries in `catalog-graph`)

If the domain is unclear, ask the user. If a new domain is needed, create the folder.

After creating files, **update `docs/ai/domain-knowledge/README.md`** with an entry linking to the new knowledge doc.

### Summary File (`knowledge-{name}.md`)
- `<!-- AI-CONTEXT: ... -->` header — use this format:
  ```
  <!-- AI-CONTEXT: {feature} — FE: {fe-path} — BE: {be-path} — READS_FROM: {upstream-doc or data-source} — WRITES_TO: {downstream-doc or ES index} — Tech: {key-tech} -->
  ```
  Include `READS_FROM` / `WRITES_TO` only when relevant (e.g., a collator writes to ES, a FE reads from BE API).
  This makes data-flow relationships machine-readable from the first line alone.
- Overview (purpose, 2–3 sentences)
- Architecture diagram (one mermaid sequenceDiagram or flowchart)
- Key Concepts table (concept → file → one-line description)
- Dependencies table (layer → file → purpose)
- Cross-references to detail files
- Metadata (date, depth, files touched)
- Next Steps

### Detail File (`knowledge-{name}-detail.md`)
- Full implementation walkthrough (all numbered sections)
- Reference source by path + line range, not inline code
- Visual diagrams (mermaid) for complex flows
- Additional Insights section
- Only embed code when the pattern is non-obvious from the source

### Topic Files (`knowledge-{name}-{topic}.md`) — optional
- Standalone reference for reusable concepts (e.g., a library API, SPARQL patterns)
- Can be shared across multiple knowledge docs

## Writing Rules for AI Readability
- **Progressive disclosure**: Put 80% of value in the summary file. Details behind cross-refs.
- **File refs over inline code**: Write `**File:** path/to/file.ts (lines 45–52)` instead of pasting the code.
- **One concept per sentence**: Avoid compound sentences with multiple technical facts.
- **Tables over prose**: Use tables for mappings, dependencies, concept lists.
- **Mermaid over text**: Use diagrams for flows, sequences, and hierarchies.

## Validation
- Summary file is under 150 lines.
- Summary starts with `<!-- AI-CONTEXT: ... -->` with `READS_FROM`/`WRITES_TO` if data flows exist.
- All Output Template sections are covered across the file set.
- No inline code blocks longer than 5 lines (reference the source instead).
- Summarize key insights, open questions, and related areas for deeper dives.
- **No content duplicated** from an existing knowledge doc — use cross-reference links instead.
- **Cross-references are bidirectional** — if doc A links to doc B, doc B must also link to doc A.
- Confirm file paths and remind to commit.
