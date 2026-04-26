# Step 5 · Verdict & Report

> **Status:** ✅ Always runs  
> **Part of:** [review-lifecycle-summary.md](./review-lifecycle-summary.md)

---

## When to Use This Doc

Load when:
- Step 5 (Verdict & Report) is starting — always runs after Step 4
- `review-coordinator` is synthesizing findings and writing the PR review report
- Checking output report format, verdict logic, or tone guidelines
- Orchestrator is computing `state.metrics.totals` after Step 5 completes

> 📐 **Context budget:** ≤ 6 000 tokens. Pass `filtered_findings` + `scope_summary` only — NOT raw diffs.

Keywords: verdict, report, review-coordinator, APPROVED, NEEDS_CHANGES, MUST_FIX, report format, totals, tone guidelines, Always runs

---

## Overview

**Agent:** `review-coordinator`

**Primary goal:** Synthesize all filtered findings from Step 4 · Signal Filter into a structured, severity-grouped report. Determine the final verdict. Write the report file. Surface results to user.

**Exit condition:** Report written to `ai-workspace/reviews/pr-{id}-review.md` → Orchestrator triggers cleanup → done. On failure → ESCALATE (cannot produce report without synthesis).


## Internal Flow

```mermaid
flowchart LR
    IN([Step 4 filtered_findings\n+ Step 1 scope_summary]) --> E1
    E1[Group findings by severity:\nMUST_FIX · SUGGESTION · NITPICK] --> E2
    E2[Determine overall verdict] --> E3
    E3[Write report file\nai-workspace/reviews/pr-{id}-review.md] --> E4
    E4[Return JSON output\nto Orchestrator] --> OUT([Orchestrator triggers\nworktree cleanup])

    E2 --> V1{Any MUST_FIX?}
    V1 -->|yes| VD1[🔴 MUST_FIX]
    V1 -->|no| V2{Any SUGGESTION?}
    V2 -->|yes| VD2[🟡 NEEDS_CHANGES]
    V2 -->|no| VD3[✅ APPROVED]
```

---

## 🤖 Agent Composition

| Role | Agent | Note |
|------|-------|------|
| **Synthesis coordinator** | `review-coordinator` | 📋 Custom agent — shared with dev-lifecycle Phase 2, 3, 6, 8. Different invocation for review pipeline. |

---

## Invocation Prompt (Orchestrator → `review-coordinator`)

```
You are being invoked as Review Coordinator for PR #{pr_id} — Step 5: Verdict & Report.

## Your Task
Synthesize all filtered findings and produce the final review report.

1. Group findings by severity: MUST_FIX → SUGGESTION → NITPICK
2. Determine overall verdict:
   - Any MUST_FIX present → verdict = MUST_FIX
   - Only SUGGESTION → verdict = NEEDS_CHANGES
   - Only NITPICK or empty → verdict = APPROVED
3. Write the report to: {output_path}
4. Return JSON verdict to Orchestrator

## Input
Filtered findings: {Step 4 filtered_findings}
Scope summary: {Step 1 scope_summary}
PR metadata: pr_id={id}, pr_branch={branch}, pr_author={author|unknown}, base_branch={base}
Partial failures (if any): {state.escalations list}
Architecture findings (if deep): {Step 2 architecture_findings | none}
Removal log: {Step 4 removed_reasons}

## Behavioral Rules
- Every MUST_FIX MUST get its own named section with Issue + Fix
- SUGGESTIONS MUST be grouped by file — NEVER one section per finding
- NITPICKS are a flat bullet list — no subheadings
- If partial failures occurred: MUST add ⚠️ banner at top of report
- Scope Summary section is ALWAYS included — even if APPROVED
- NEVER use "you" or "your mistake" — findings are about CODE, not the person
- If APPROVED with only nitpicks: lead with ✅ and keep tone positive

## Output Required
Write the report file (format below), then return JSON:
{
  "verdict": "APPROVED|NEEDS_CHANGES|MUST_FIX",
  "must_fix_count": N,
  "suggestion_count": N,
  "nitpick_count": N,
  "report_path": "{output_path}",
  "partial_failure": true|false,
  "perf": {
    "started_at": "<ISO-8601 when you started>",
    "completed_at": "<ISO-8601 now>",
    "duration_ms": <elapsed ms>,
    "tokens_input": <estimated input tokens>,
    "tokens_output": <estimated output tokens>,
    "tokens_total": <sum>,
    "context_efficiency": <tokens_output / tokens_input>
  }
}
```

---

## Output Report Format

**Location:** `ai-workspace/reviews/pr-{id}-review.md`

````markdown
# PR Review — #{pr_id}: {pr_branch}

| Field | Value |
|---|---|
| **Author** | {pr_author \| unknown} |
| **Branch** | `{pr_branch}` → `{base_branch}` |
| **Reviewed at** | {ISO-8601} |
| **Files changed** | {count} |
| **Verdict** | 🔴 MUST FIX \| 🟡 NEEDS CHANGES \| ✅ APPROVED |

{if partial_failure:}
> ⚠️ **Partial review** — the following agents failed: {list}. Findings may be incomplete.

---

## 🔴 Must Fix ({count})

> Blocking issues — must be resolved before merge.

### [{category}] {file}:{line}
**Issue:** {finding}  
**Fix:** {suggestion}

---

## 🟡 Suggestions ({count})

> Non-blocking but strongly recommended.

### {file}
- **[{category}] line {line}:** {finding} → {suggestion}

---

## 🔵 Nitpicks ({count})

> Minor style / preference items. Author's discretion.

- `{file}:{line}` — {finding}

---

## 📋 Scope Summary

{scope_summary from Step 1 · Scope Analysis}

---

## ⚡ Performance

| Step | Agent | Duration | Tokens (in / out) | Notes |
|------|-------|----------|-------------------|-------|
| Setup | *(orchestrator)* | {setup.duration_ms} ms | — | fetch: {git_fetch_ms} ms · worktree: {worktree_create_ms} ms |
| 1 · Scope Analysis | `gem-researcher` | {researcher.duration_ms} ms | {tokens_input} / {tokens_output} | {files_read} files read |
| 2 · Architecture Critique | `gem-critic` | {critic.duration_ms} ms \| *skipped* | {tokens_input} / {tokens_output} \| — | {files_read} files read |
| 3a · Code Review | `gem-reviewer` | {3a.duration_ms} ms | {tokens_input} / {tokens_output} | {findings_count} findings |
| 3b · Security Review | `se-security-reviewer` | {3b.duration_ms} ms | {tokens_input} / {tokens_output} | {findings_count} findings · {owasp_passes} OWASP pass(es) |
| 3c · FE Review | `fe-backstage-reviewer` | {3c.duration_ms} ms \| *skipped* | {tokens_input} / {tokens_output} \| — | {findings_count} findings · {files_reviewed_count} files |
| 3 · Wall clock | *(parallel)* | **{wall_clock_ms} ms** | — | Parallel savings: {sum(3a,3b,3c) - wall_clock_ms} ms |
| 4 · Signal Filter | `doublecheck` | {doublecheck.duration_ms} ms | {tokens_input} / {tokens_output} | {findings_in} in → {findings_out} out |
| 5 · Verdict & Report | `review-coordinator` | {coordinator.duration_ms} ms | {tokens_input} / {tokens_output} | — |
| **Total** | | **{totals.wall_clock_ms} ms** | **— / {totals.tokens_total}** | {totals.findings_raw} raw → {totals.findings_after_filter} filtered |

> *All token counts are estimates. Parallel savings = sum of individual reviewer durations minus actual wall clock time for Step 3.*

---

*Generated by review-orchestrator · {ISO-8601}*
````

---

## Verdict Logic

| Condition | Verdict | Icon |
|-----------|---------|------|
| Any `MUST_FIX` in filtered findings | `MUST_FIX` | 🔴 |
| No `MUST_FIX`, but any `SUGGESTION` | `NEEDS_CHANGES` | 🟡 |
| Only `NITPICK` or zero findings | `APPROVED` | ✅ |

---

## Output Contract (Step 5 → Orchestrator)

```json
{
  "verdict": "NEEDS_CHANGES",
  "must_fix_count": 0,
  "suggestion_count": 4,
  "nitpick_count": 2,
  "report_path": "ai-workspace/reviews/pr-42-review.md",
  "partial_failure": false,
  "perf": {
    "context_budget_exceeded": 0,
    "started_at": "ISO-8601",
    "completed_at": "ISO-8601",
    "duration_ms": 1820,
    "tokens_input": 3600,
    "tokens_output": 980,
    "tokens_total": 4580,
    "context_fill_rate": 0.018,
    "context_efficiency": 0.27
  }
}
```

Orchestrator **computes totals** from all step metrics and writes to `state.metrics.totals`, then surfaces to user:

```json
{
  "pr_id": "42",
  "verdict": "NEEDS_CHANGES",
  "must_fix": 0,
  "suggestions": 4,
  "nitpicks": 2,
  "report": "ai-workspace/reviews/pr-42-review.md",
  "worktree_removed": true,
  "metrics": {
    "wall_clock_ms": 22400,
    "tokens_total": 53940,
    "findings_raw": 18,
    "findings_after_filter": 15
  }
}
```

`state.metrics.totals` written by orchestrator after Step 5:

```json
{
  "wall_clock_ms": 22400,            // ISO completed_at - created_at
  "tokens_total": 53940,             // sum of all tokens_total across all steps
  "tokens_by_step": {
    "researcher": 7620,
    "critic": 9840,                  // 0 if skipped
    "reviewer_3a": 12500,
    "reviewer_3b": 9800,
    "reviewer_3c": 7200,             // 0 if skipped
    "doublecheck": 5600,
    "coordinator": 4580
  },
  "findings_raw": 18,                // sum of findings_count from all reviewers
  "findings_after_filter": 15,       // doublecheck.findings_out
  // ── Context Health ──────────────────────────────────────────────────────
  "context_efficiency_by_step": {    // tokens_output / tokens_input per step
    "researcher": 0.11,
    "critic": 0.07,
    "reviewer_3a": 0.17,
    "reviewer_3b": 0.16,
    "reviewer_3c": 0.18,
    "doublecheck": 0.17,
    "coordinator": 0.21
  },
  "token_inflation_index": 1.4,      // max(tokens_input[stepN]) / tokens_input[step1] — target < 3
  "context_budget_exceeded_steps": [] // list of steps that hit their token budget
}
```

---

## Failure Policy

| Failure | Policy |
|---------|--------|
| `review-coordinator` fails | ❌ **ESCALATE** — cannot produce report without synthesis |
| `review-coordinator` times out | ❌ **ESCALATE** — same |
| Report file write fails | ❌ **ESCALATE** — print report content to user directly as fallback, then cleanup |

---

## Tone Guidelines

| Situation | Tone |
|-----------|------|
| APPROVED | Positive first. State what was done well, then list nitpicks if any. |
| NEEDS_CHANGES | Constructive. Findings are about code patterns, not intent. |
| MUST_FIX | Direct and clear. State the risk explicitly. Provide the exact fix. |
| Partial failure | Transparent. State clearly which agent failed and what was missed. |

> ⚠️ Never use second-person language ("you did", "your code") — framing is code-centric, not person-centric.

