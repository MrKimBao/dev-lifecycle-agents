# Phase 6 — Check Implementation

> **Status:** ⏳ Pending  
> **Part of:** [dev-lifecycle-summary.md](./dev-lifecycle-summary.md)

---

## When to Use This Doc

Load when:
- Orchestrator routes to Phase 6 after all Phase 4/5 tasks are done
- Implementation check against the design doc is needed
- `state.domain.has_frontend = true` → include `fe-backstage-reviewer` in parallel review set

> 📐 **Context budget:** ≤ 10 000 tokens. Pass changed file list + relevant design doc sections — NOT full design.

Keywords: check implementation, drift check, BUI compliance, gem-reviewer, se-security-reviewer, fe-backstage-reviewer, doublecheck, design deviation

---

## Overview

**Persona:** Meticulous auditor. Reads every changed file against the design doc. Nothing ships without a traceable line from design → implementation.

**Primary goal:** Verify that all changed code matches the design doc and requirements. Flag deviations, logic gaps, security issues, and missing pieces.

**Exit condition:** APPROVED → Phase 6.5 (manual verify). NEEDS_REVISION → Phase 3 (design wrong) or Phase 4 (implementation wrong).

---

## Internal Agent Pipeline

```mermaid
flowchart LR
    IN([Changed files + docs]) --> A1
    A1[knowledge-doc-auditor\ndrift check] --> A2 & A3 & A4
    A2[gem-reviewer\ncode review] --> A5
    A3[se-security-reviewer\nsecurity pass] --> A5
    A4[fe-backstage-reviewer\nBUI compliance · conditional] --> A5
    A5[doublecheck\nverify findings] --> RC
    RC[review-coordinator\nsynthesize + verdict] --> OUT

    OUT{verdict}
    OUT -->|APPROVED| NEXT([Phase 6.5])
    OUT -->|design wrong| P3([Phase 3])
    OUT -->|implementation wrong| P4([Phase 4])
```

---

## Steps

1. **Drift check** — `knowledge-doc-auditor`: compare changed files vs design doc → ALIGNED / DEVIATION / UNDOCUMENTED per file
2. **Code review** — `gem-reviewer` + `se-security-reviewer` in **parallel**: correctness + security pass on all changed files
3. **BUI compliance** *(conditional — only if `has_frontend: true`)* — `fe-backstage-reviewer` in **parallel** with step 2:
   - Scope: all `[fe]`-tagged changed files
   - Checks: BUI component usage matches the `## BUI Design Constraints` annotation; no MUI leaks; no `import React`; direct imports; CSS Modules; `MuiV7ThemeProvider` applied where required; Remix Icons used
   - Severity mapping: BUI component replaced incorrectly = BLOCKING; missing MuiV7ThemeProvider wrap = BLOCKING; style violation = SUGGESTION
4. **Verify findings** — `doublecheck`: remove hallucinated findings from ALL reviewers (including `fe-backstage-reviewer`), confirm severity classifications
5. **Synthesize & verdict** — `review-coordinator`: apply Phase 6 behavioral rules → APPROVED / NEEDS_REVISION

**Behavioral rules:**
- Every changed file MUST be ALIGNED with the design doc — DEVIATION is always blocking
- Logic gaps, unhandled edge cases, missing error handling = blocking if in critical paths
- CRITICAL security findings = ALWAYS blocking — no exceptions
- NEVER approve if unit tests are missing for changed files
- Distinguish cause: design was wrong (→ Phase 3) vs implementation deviated (→ Phase 4)

**Gates:**
- ⚠️ Design deviation → ESCALATE_TO_PHASE_3
- ⚠️ Implementation wrong → NEEDS_REVISION → Phase 4
- ⚠️ CRITICAL security finding → NEEDS_REVISION → Phase 4
- ✅ All ALIGNED + no blocking → Phase 6.5

---

## 🤖 Agent Composition

> `gem-reviewer`, `se-security-reviewer`, and `fe-backstage-reviewer` run in **parallel**. `fe-backstage-reviewer` is conditional — only when `has_frontend: true`. `review-coordinator` is shared with Phase 2 + 3 — same agent, Phase 6 invocation prompt.

| Role | Agent | Status | Scope | Note |
|------|-------|--------|-------|------|
| **Drift checker** | `knowledge-doc-auditor` | ✅ Installed | Design doc vs implementation alignment per file | Runs first — fast structural pass |
| **Code reviewer** | `gem-reviewer` | ✅ Installed | Correctness, logic gaps, edge cases, error handling | Parallel with `se-security-reviewer` + `fe-backstage-reviewer` |
| **Security reviewer** | `se-security-reviewer` | ✅ Installed | OWASP pass — auth, injection, data exposure | Parallel with `gem-reviewer` |
| **BUI compliance reviewer** | `fe-backstage-reviewer` | ✅ Installed | BUI component compliance, React 18 patterns, no MUI leaks | **Conditional** — only if `has_frontend: true`. Parallel with other reviewers |
| **Output verifier** | `doublecheck` | ✅ Installed | Remove hallucinated findings, confirm severity | Runs before coordinator |
| **Final synthesizer** | `review-coordinator` | 📋 Custom agent | Apply Phase 6 rules → APPROVED / NEEDS_REVISION | Shared with Phase 2 + 3 — see spec in phase-2-reviewer.md |

> 📄 **`review-coordinator` full spec** (persona, reasoning techniques): [phase-2-reviewer.md](./phase-2-reviewer.md#-custom-agent-review-coordinator)

---

## Invocation Prompts

> `knowledge-doc-auditor`
```
You are being invoked as Implementation Drift Checker for feature {feature-name}.

## Your Task
Compare all changed files against the design doc.
Flag each file: ALIGNED | DEVIATION | UNDOCUMENTED.

## Input
Changed files: {git diff --stat output}
Design doc: docs/ai/design/feature-{name}.md

## Output Required
Return JSON: { "drift": [{ "file": "...", "verdict": "ALIGNED|DEVIATION|UNDOCUMENTED", "detail": "..." }] }
```

> `gem-reviewer`
```
You are being invoked as Implementation Reviewer for feature {feature-name}.

## Your Task
File-by-file review of all changed code. Check: correctness, logic gaps,
edge cases not handled, redundancy, performance hotspots, error handling gaps.

## Input
Changed files: {file list + diffs}
Design doc: docs/ai/design/feature-{name}.md

## Output Required
Return JSON: { "findings": [{ "file": "...", "issue": "...", "severity": "BLOCKING|SUGGESTION" }] }
```

> `se-security-reviewer`
```
You are being invoked as Security Reviewer for feature {feature-name}.

## Your Task
Security-focused pass: authentication, authorization, input validation,
injection risks, data exposure, insecure defaults, missing rate limiting.

## Input
Changed files: {file list + diffs}

## Output Required
Return JSON: { "security_findings": [{ "file": "...", "category": "...", "severity": "CRITICAL|HIGH|MED|LOW" }] }
```

> `doublecheck`
```
You are being invoked as Output Verifier for feature {feature-name}.

## Your Task
Verify gem-reviewer, se-security-reviewer, and fe-backstage-reviewer outputs are grounded in actual code.
Remove findings not supported by evidence. Confirm severity classifications.

## Input
gem-reviewer output: {json}
se-security-reviewer output: {json}
fe-backstage-reviewer output: {json} (if applicable)
Source files: {changed files}

## Output Required
Return JSON: { "verified_findings": [...], "removed_count": N }
```

> `fe-backstage-reviewer` — BUI Compliance *(conditional — only if `has_frontend: true`)*
```
You are being invoked as BUI Compliance Reviewer for feature {feature-name}.

## Your Task
Review all frontend-tagged changed files for BUI compliance and React 18 patterns.
Compare actual implementation against the ## BUI Design Constraints block in the design doc.

## Input
Changed FE files: {[fe]-tagged file list + diffs}
BUI Design Constraints: {## BUI Design Constraints block from design doc}
Coding standards: AGENTS.md + .github/coding-standards.md

## What to check (file by file)
- BUI component matches annotation (e.g., design says `<Table>` but code uses MUI DataGrid → BLOCKING)
- No `import React` (use react-jsx transform)
- No barrel imports — must use direct imports
- No `makeStyles` — use CSS Modules
- No `@material-ui/icons` — use `@remixicon/react`
- MUI v7 components (Button, Chip, Card, Alert, Divider, IconButton) wrapped in `<MuiV7ThemeProvider>`
- Backstage components (InfoCard, LinkButton, Link, Progress) — no wrapper needed

## Output Required
Return JSON: {
  "fe_findings": [{ "file": "...", "issue": "...", "severity": "BLOCKING|SUGGESTION", "rule": "..." }],
  "bui_compliant": true|false
}
```

> `review-coordinator` — Phase 6 variant
```
You are being invoked as Review Coordinator for feature {feature-name} — Phase 6 (Check Implementation).

## Your Task
Synthesize all sub-agent outputs. Apply Phase 6 behavioral rules. Produce final verdict.

## Input
knowledge-doc-auditor output: {json — drift report}
doublecheck output: {json — verified findings}
Source docs: design + requirements

## Behavioral Rules to Enforce
- DEVIATION in drift report = blocking (unless explicitly documented as intentional)
- CRITICAL security finding = always blocking
- Missing unit tests for changed files = blocking
- BUI BLOCKING violation (wrong component, missing MuiV7ThemeProvider) = blocking — route to Phase 4 FE stream
- Distinguish cause: design was wrong (ESCALATE_TO_PHASE_3) vs implementation deviated (NEEDS_REVISION → Phase 4)
- Apply CoT: walk file-by-file before concluding

## Output Required
Return JSON: {
  "verdict": "APPROVED | NEEDS_REVISION | ESCALATE_TO_PHASE_3",
  "blocking_issues": [...],
  "suggestions": [...],
  "blocking": true|false
}
```

---

## Output Contract (Phase-6 → Orchestrator)

```json
{
  "verdict": "APPROVED | NEEDS_REVISION | ESCALATE_TO_PHASE_3",
  "blocking_issues": ["..."],
  "suggestions": ["..."],
  "blocking": true,
  "perf": {
    "started_at": "ISO-8601",
    "completed_at": "ISO-8601",
    "duration_ms": 13400,
    "tokens_input": 11200,
    "tokens_output": 1600,
    "tokens_total": 19600,
    "context_fill_rate": 0.056,
    "context_budget_exceeded": false,
    "findings_raw": 12,
    "findings_after_filter": 8,
    "filter_ratio": 0.33
  }
}
```

> Orchestrator writes `perf` block to `state.metrics.phase_6`. `filter_ratio` is computed by orchestrator: `(raw - filtered) / raw`.

