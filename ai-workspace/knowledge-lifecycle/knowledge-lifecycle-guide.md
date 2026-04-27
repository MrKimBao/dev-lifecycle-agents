# Knowledge Lifecycle — Orchestrator Guide

**Modes:** `new` (full capture) · `update` (stale patch)

---

## When to Use This Doc

Load when:
- `knowledge-orchestrator` needs pipeline routing logic, mode decision table, or context contracts
- `gem-orchestrator` needs to understand how to call knowledge-orchestrator for stale doc updates
- Debugging a failed capture, stale patch, or inter-orchestrator handoff

> 📐 **Context budget:** ≤ 8 000 tokens. Load by section — do NOT pass the full doc unless needed.

Keywords: knowledge capture, update stale, knowledge orchestrator, inter-orchestrator, domain knowledge, doc lifecycle

---

## Architecture Overview

```mermaid
flowchart TD
    classDef user     fill:#0891b2,stroke:#0e7490,color:#fff
    classDef capture  fill:#7c3aed,stroke:#6d28d9,color:#fff
    classDef update   fill:#0f766e,stroke:#0d5e56,color:#fff
    classDef agent    fill:#475569,stroke:#334155,color:#fff
    classDef gate     fill:#f59e0b,stroke:#b45309,color:#000
    classDef done     fill:#22c55e,stroke:#15803d,color:#fff
    classDef fail     fill:#ef4444,stroke:#991b1b,color:#fff
    classDef caller   fill:#b45309,stroke:#92400e,color:#fff

    User([👤 User]):::user
    GemOrch([⚙️ gem-orchestrator\nPhase 1]):::caller

    subgraph KO [knowledge-orchestrator]
        direction TB
        ModeNew[Mode: new]:::capture
        ModeUpd[Mode: update]:::update

        A_new[A · Context Loader]:::agent
        B_new[B · Explorer\ngem-researcher]:::agent
        C_new[C · Dep Analyzer\ngem-researcher]:::agent
        D_new[D · Writer\ngem-documentation-writer]:::agent
        E_new[E · Auditor\nknowledge-doc-auditor]:::agent
        GATE([⏸ User Gate\nreview output]):::gate

        A_upd[A · Diff Loader]:::agent
        B_upd[B · Patcher\ngem-documentation-writer]:::agent
        C_upd[C · Validator\nknowledge-doc-auditor]:::agent
    end

    DONE_new([✅ Docs committed]):::done
    DONE_upd([✅ Return updated JSON]):::done
    FAIL([🚨 Escalate / Return failed]):::fail

    User -->|capture knowledge for X| ModeNew
    GemOrch -->|stale detected — blocking call| ModeUpd

    ModeNew --> A_new --> B_new --> C_new --> D_new --> E_new
    E_new -->|APPROVED| GATE --> DONE_new
    E_new -. ⚠️ NEEDS_REVISION max 2 loops .-> D_new
    E_new -->|❌ > 2 loops| FAIL

    ModeUpd --> A_upd --> B_upd --> C_upd
    C_upd -->|APPROVED| DONE_upd
    C_upd -. ⚠️ retry max 1 .-> B_upd
    C_upd -->|❌ failed| FAIL

    DONE_upd -->|JSON response| GemOrch
```

> *(Mũi tên nét đứt `⚠️` = retry. `❌` = hard failure → escalate or return `status: "failed"`)*

---

## Mode Decision Table

| Trigger | Mode | Gates | Pipeline |
|---------|------|-------|----------|
| `capture knowledge for X` (user) | `new` | 1 user gate (end) | A→B→C→D→E→gate |
| `update knowledge for X` (user) | `update` | None (fully auto) | A→B→C |
| Called by `gem-orchestrator` (JSON) | `update` | None (fully auto) | A→B→C |

---

## Mode: new — Pipeline Steps

| Step | Agent | Input | Output | Skip condition |
|------|-------|-------|--------|----------------|
| **A** Context Loader | *(orchestrator reads directly)* | Knowledge index + domain summaries | `existing_facts[]`, `gaps_found[]` | `force` keyword |
| **B** Explorer | `gem-researcher` | Entry point + A output | Purpose, exports, source refs | — |
| **C** Dep Analyzer | `gem-researcher` | B output | Dependency graph depth 3 (5 if `deep`) | `fast` keyword |
| **D** Writer | `gem-documentation-writer` | B+C output + A facts | Summary ≤150 lines + detail file | — |
| **E** Auditor | `knowledge-doc-auditor` | Doc paths from D | `APPROVED` or `NEEDS_REVISION` + issues | — |

**Revision loop:** E → D max **2 loops** before escalating.

**`deep` extra step:** `gem-critic` architecture pass inserted between C and D.

---

## Mode: update — Pipeline Steps

| Step | Agent | Input | Output | Notes |
|------|-------|-------|--------|-------|
| **A** Diff Loader | *(orchestrator)* | `target_doc` + `changed_files[]` | `stale_sections[]` | Returns `no_changes_needed` if nothing stale |
| **B** Patcher | `gem-documentation-writer` | Existing doc + stale sections | `sections_patched[]` | Patch ONLY stale sections |
| **C** Validator | `knowledge-doc-auditor` | Updated doc | `APPROVED` or `NEEDS_REVISION` | Max **1** retry |

**Return to caller:** `{ status, doc_path, sections_patched, summary, perf }`

---

## Inter-Orchestrator Communication

### gem-orchestrator → knowledge-orchestrator (call)

```jsonc
{
  "mode": "update",
  "caller": "gem-orchestrator/phase-1",
  "target_doc": "docs/ai/domain-knowledge/{domain}/knowledge-{name}.md",
  "changed_files": ["plugins/.../src/..."],
  "feature": "feature-name"
}
```

### knowledge-orchestrator → gem-orchestrator (response)

```jsonc
{
  "status": "updated|failed|no_changes_needed",
  "doc_path": "...",
  "sections_patched": ["Dependencies table"],
  "summary": "Updated X — Y unchanged",
  "perf": {
    "duration_ms": 3800,
    "tokens_input": 0,
    "context_fill_rate": 0,        // tokens_input / 200_000
    "filter_ratio": 0.1,           // (findings_raw - accepted) / findings_raw — from Validator
    "retry_count": 0,
    "context_budget_exceeded": false
  }
}
```

### gem-orchestrator behavior on response

| Response `status` | gem-orchestrator action |
|---|---|
| `updated` | Resume Phase 1 with fresh knowledge ✅ |
| `no_changes_needed` | Resume Phase 1 immediately ✅ |
| `failed` | Mark doc `[STALE — not updated]` in context → warn user → continue Phase 1 |
| Timeout (>60s) | Treat as `failed` |

### Multiple stale docs

`gem-orchestrator` spawns **parallel** update calls — one per stale doc. Each gets its own state file. Blocks Phase 1 until **all** resolve.

---

## State File

**Location:** `ai-workspace/temp/knowledge-state-{slug}.json`

```jsonc
{
  "slug": "catalog-graph",
  "mode": "new|update",
  "caller": "user|gem-orchestrator/phase-1",
  "status": "pending|running|done|failed",
  "keywords": [],
  "target": {
    "entry_point": "...",
    "domain": "catalog-graph",
    "business_doc": "docs/ai/domain-knowledge/catalog-graph/business/catalog-graph.md",
    "dev_doc":      "docs/ai/domain-knowledge/catalog-graph/dev/catalog-graph.md",
    "detail_doc":   "docs/ai/domain-knowledge/catalog-graph/dev/catalog-graph-detail.md"
  },
  "pipeline": {
    "context_loader": null,   // { status, existing_facts_count, gaps_found_count }
    "explorer":       null,   // { status, perf: { duration_ms, tokens_input, context_fill_rate } }
    "dep_analyzer":   null,   // { status, perf: { ... } }
    "writer":         null,   // { status, perf: { ... } }
    "auditor":        null    // { status, findings_raw, findings_accepted, filter_ratio, perf: { ... } }
  },
  "revision_loops": 0,
  "stale_sections": [],
  "sections_patched": [],
  "escalations": [],
  "created_at": "ISO-8601",
  "completed_at": null,
  // ── Performance Metrics ───────────────────────────────────────────────────
  "metrics": {
    "duration_ms": null,
    "tokens_total": null,
    "context_fill_rate_max": null,   // max(tokens_input / 200_000) across all steps
    "context_budget_exceeded": false,
    // mode: new only
    "revision_loops": 0,
    "filter_ratio": null,            // from Auditor (Step E)
    // mode: update only
    "retry_count": 0,
    "filter_ratio_update": null      // from Validator (Step C)
  }
}
```

---

## Magic Keywords

| Keyword | Effect | Mode |
|---------|--------|------|
| `deep` | Dep graph depth 5 + `gem-critic` pass before writer | `new` |
| `fast` | Skip Dep Analyzer (Step C) | `new` |
| `force` | Skip Context Loader (Step A) — full re-capture | `new` |

---

## Context Contracts

| Step | Receives | NOT passed |
|------|----------|-----------|
| A (Context Loader) | Knowledge index path + domain | Source files |
| B (Explorer) | Entry point path + A.existing_facts | Full knowledge docs |
| C (Dep Analyzer) | B output + entry point path | A facts, full source |
| D (Writer) | B+C output + A gaps + capture skill rules | Full source files |
| E/C (Auditor/Validator) | Doc paths only | Pipeline history |

---

## Doc Locations

```
docs/ai/domain-knowledge/
├── README.md                              # Index — always updated after new capture
├── common/                                # Shared technical references (no audience split)
│   └── knowledge-{name}.md
└── {domain}/
    ├── business/
    │   └── {name}.md                      # PO/BA layer — plain language, no code, no limit
    └── dev/
        ├── {name}.md                      # AI compact ≤ 250 lines (business summary + technical overview)
        └── {name}-detail.md               # Full walkthrough — code refs, patterns, no limit
```

**Audience rules:**
- `business/` — PO / BA / non-tech: flow, terminology, business rules. No source file refs.
- `dev/{name}.md` — AI agents load this first: business context (~30 lines) + technical overview (~100 lines) + key patterns (~50 lines) + cross-refs.
- `dev/{name}-detail.md` — load on demand for implementation specifics.
- `common/` — technical references shared across 2+ domains. No `business/dev/` split.

---

## ⚡ Performance Metrics

Each step returns a `perf` block. Orchestrator writes it to `state.pipeline.<step>` immediately on receipt.

| Metric | Source | Purpose |
|--------|--------|---------|
| `duration_ms` | All steps | Wall clock per step |
| `tokens_input` | All steps | Estimated token input |
| `context_fill_rate` | `tokens_input / 200_000` | > 0.5 = warning; > 0.8 = truncation risk |
| `context_budget_exceeded` | All steps | `true` when input budget exceeded |
| `revision_loops` | Mode `new` — Step E | E→D loops before APPROVED |
| `filter_ratio` | Step E (Auditor) + Step C (Validator) | `(findings_raw - accepted) / findings_raw` — hallucination rate |
| `retry_count` | Mode `update` — Step C | Validator retry count |

### Input Budgets (soft limits)

| Step | Budget | Action when exceeded |
|------|--------|---------------------|
| B (Explorer) | ≤ 8 000 tokens | Split entry point scope — ask user |
| C (Dep Analyzer) | ≤ 6 000 tokens | Reduce depth to 2, alert |
| D (Writer) | ≤ 10 000 tokens | Pass summaries not full source output |
| E/C (Auditor/Validator) | ≤ 4 000 tokens | Pass doc paths only — already enforced by Context Contracts |

> **`filter_ratio` target:** < 0.30 — if Auditor consistently > 0.35, Writer output quality is low.

---

## Failure Handling

| Failure point | Mode | Action |
|---|---|---|
| Explorer blocked | `new` | Escalate to user |
| Writer > 2 revision loops | `new` | Escalate to user |
| Validator fail after 1 retry | `update` | Return `status: "failed"` to caller |
| Diff Loader — doc not found | `update` | Return `status: "failed", reason: "doc not found"` |
| Timeout > 60s | `update` | Caller treats as `failed` |

