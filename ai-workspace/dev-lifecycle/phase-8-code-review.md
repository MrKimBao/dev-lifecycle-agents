# Phase 8 â€” Code Review

> **Status:** â³ Pending  
> **Part of:** [dev-lifecycle-guide.md](./dev-lifecycle-guide.md)

---

## When to Use This Doc

Load when:
- Phase 7 is complete â€” all tests green, 100% coverage confirmed
- Final pre-push review is being performed
- `review-coordinator` is invoked for Phase 8 verdict (READY_TO_PUSH / NEEDS_FIX routing)

> ðŸ“ **Context budget:** â‰¤ 10 000 tokens. Pass changed file list + diffs + Phase 7 coverage report.

Keywords: code review, pre-push, READY_TO_PUSH, final review, NEEDS_FIX, janitor, devils-advocate, review-coordinator Phase 8

---

## Overview

**Persona:** Uncompromising reviewer. Nothing ships without a traceable verdict. Every finding is classified, grounded in code, and backed by evidence â€” never guessed.

**Primary goal:** Final pre-push review â€” correctness, security, code quality, design alignment, docs completeness. Gate: all BLOCKING issues resolved before PR.

**Entry condition:** Phase 7 complete â€” all tests green, coverage at 100%.

**Exit condition:** `READY_TO_PUSH` â†’ push and open PR. Blocking issues in code â†’ Phase 4. Missing tests â†’ Phase 7.

---

## Internal Agent Pipeline

```mermaid
flowchart LR
    IN([Phase 7 passed\n+ changed files]) --> GR & SEC
    GR[gem-reviewer\nfile-by-file code review] --> VERI
    SEC[se-security-reviewer\nOWASP final pass] --> VERI
    VERI[doublecheck\nverify findings] --> UJ[janitor\ncleanup pass]
    UJ --> DA[devils-advocate\nstress-test]
    DA --> KDA[knowledge-doc-auditor\ndocs completeness]
    KDA --> RC[review-coordinator\nsynthesize + verdict]
    RC --> OUT

    OUT{verdict}
    OUT -->|READY_TO_PUSH| DONE([Push + PR])
    OUT -->|blocking in code| P4([Phase 4])
    OUT -->|missing tests| P7([Phase 7])
```

> `gem-reviewer` and `se-security-reviewer` run in **parallel**. `doublecheck` filters hallucinations first â€” `review-coordinator` applies Phase 8 rules and produces the final routing verdict.

---

## Steps

1. **Diff snapshot** â€” `git status -sb` + `git diff --stat` to scope the review.
2. **Code review** â€” `gem-reviewer` + `se-security-reviewer` in **parallel**:
   - gem-reviewer: file-by-file correctness, logic, edge cases, redundancy, performance, error handling, test coverage.
   - se-security-reviewer: OWASP top 10 pass â€” auth, injection, data exposure, secrets, missing validation.
3. **Verify findings** â€” `doublecheck`: remove hallucinated issues, confirm severity classifications across both review outputs.
4. **Cleanup pass** â€” `janitor`: dead code, unused imports, inconsistent naming, magic numbers, missing inline comments on complex logic.
5. **Stress test** â€” `devils-advocate`: simulate concurrent users, malformed input, missing env vars, downstream failures, edge data (empty / null / max size).
6. **Docs completeness** â€” `knowledge-doc-auditor`: verify all 5 `docs/ai/` files are complete, up-to-date, and consistent with final implementation.
7. **Synthesize & verdict** â€” `review-coordinator`: apply Phase 8 behavioral rules â†’ `READY_TO_PUSH` / `NEEDS_FIX` + routing decision.

**Final checklist (must pass before push):**
- [ ] Design match â€” implementation matches design doc
- [ ] No logic gaps â€” all edge cases handled
- [ ] Security addressed â€” no CRITICAL/HIGH findings
- [ ] Tests cover all changes â€” 100% coverage verified
- [ ] Docs updated â€” all `docs/ai/` files complete and accurate

**Behavioral rules:**
- CRITICAL security finding = ALWAYS blocking â€” no exceptions â†’ Phase 4
- BLOCKING code finding = MUST fix before push â†’ Phase 4
- Missing test coverage = MUST fix â†’ Phase 7
- `doublecheck` MUST remove findings not grounded in actual code before presenting to user
- `janitor` reports only â€” NEVER auto-applies unless user explicitly says to apply

**Gates:**
- âš ï¸ CRITICAL security finding â†’ BLOCKING â†’ Phase 4
- âš ï¸ BLOCKING logic / correctness issue â†’ Phase 4
- âš ï¸ Missing test coverage â†’ Phase 7
- âš ï¸ Docs incomplete â†’ `lifecycle-scribe` update, then re-verify
- âœ… All checklist items pass â†’ `READY_TO_PUSH`

---

## ðŸ¤– Agent Composition

| Role | Agent | Status | Scope | Note |
|------|-------|--------|-------|------|
| **Primary reviewer** | `gem-reviewer` | âœ… Installed | File-by-file correctness, logic, edge cases, performance | Parallel with se-security-reviewer |
| **Security final pass** | `se-security-reviewer` | âœ… Installed | OWASP top 10 â€” last chance before push | Parallel with gem-reviewer |
| **Output verifier** | `doublecheck` | âœ… Installed | Remove hallucinated findings, confirm severity | Runs right after parallel reviews |
| **Code quality** | `janitor` | âœ… Installed | Dead code, naming, unused imports, tech debt | Report-only by default |
| **Assumption challenger** | `devils-advocate` | âœ… Installed | Stress-test final implementation under failure scenarios | Runs after cleanup |
| **Docs completeness** | `knowledge-doc-auditor` | âœ… Installed | All 5 `docs/ai/` files â€” complete, accurate, no stale content | Runs after stress-test |
| **Final synthesizer** | `review-coordinator` | ðŸ“‹ Custom agent | Apply Phase 8 rules â†’ READY_TO_PUSH / NEEDS_FIX | Shared with Phase 2 + 6 â€” see spec in phase-2-reviewer.md |

> ðŸ“„ **`review-coordinator` full spec** (persona, reasoning techniques): [phase-2-reviewer.md](./phase-2-reviewer.md#-custom-agent-review-coordinator)

---

## Invocation Prompts

> `gem-reviewer`
```
You are being invoked as Code Reviewer for feature {feature-name} (final pre-push review).

## Your Task
Full file-by-file review of all changed code. Check: correctness, logic,
edge cases, redundancy, performance, error handling, test coverage completeness.

## Input
git diff --stat output: {diff}
Changed files: {list}
Design doc: docs/ai/design/feature-{name}.md

## Output Required
Per-file findings with: issue, impact severity, recommendation.
Classify: BLOCKING | FOLLOW_UP | NICE_TO_HAVE.
Return JSON: { "findings": [...], "blocking_count": N }
```

> `se-security-reviewer`
```
You are being invoked as Security Reviewer for feature {feature-name} (final pass).

## Your Task
Final security audit on the complete diff before PR. OWASP top 10 pass.
Focus: any new attack surface introduced, secrets hardcoded, missing validation.

## Input
Changed files: {list + diffs}

## Output Required
Security findings with severity. CRITICAL = must fix before push.
Return JSON: { "findings": [{ "issue": "...", "severity": "CRITICAL|HIGH|MED" }] }
```

> `janitor`
```
You are being invoked as Code Janitor for feature {feature-name}.

## Your Task
Cleanup pass on all changed files: dead code, unused imports, inconsistent naming,
magic numbers without constants, missing comments on complex logic.

## Input
Changed files: {list}
Codebase conventions: {from AGENTS.md or coding-standards.md}

## Output Required
List of cleanup items (not auto-applied â€” report only, unless told to apply).
Return JSON: { "cleanup_items": [{ "file": "...", "item": "...", "type": "dead_code|naming|..." }] }
```

> `devils-advocate`
```
You are being invoked as Final Stress Tester for feature {feature-name}.

## Your Task
Try to break the final implementation. Simulate: concurrent users, malformed input,
missing env vars, downstream service failures, edge data (empty, null, max size).
For each: does the code handle it gracefully?

## Input
Changed files: {list}
User stories: {from requirements doc}

## Output Required
Failure scenarios with handling verdict: HANDLED | UNHANDLED | PARTIAL.
UNHANDLED = blocking.
Return JSON: { "scenarios": [{ "scenario": "...", "verdict": "...", "file": "..." }] }
```

> `knowledge-doc-auditor`
```
You are being invoked as Docs Completeness Checker for feature {feature-name}.

## Your Task
Verify all 5 docs/ai/ files are complete, up-to-date, and consistent with the implementation.
Flag: missing sections, stale content, implementation notes not yet recorded.

## Input
All docs: docs/ai/{requirements,design,planning,implementation,testing}/feature-{name}.md
Changed files: {list}

## Output Required
Per-doc completeness verdict. Missing or stale items.
Return JSON: { "docs_status": [{ "doc": "...", "verdict": "COMPLETE|INCOMPLETE", "issues": [...] }] }
```

> `doublecheck`
```
You are being invoked as Output Verifier for feature {feature-name}.

## Your Task
Verify gem-reviewer and se-security-reviewer outputs are grounded in actual code.
Remove findings not supported by evidence. Confirm severity classifications.

## Input
gem-reviewer output: {json}
se-security-reviewer output: {json}
Source files: {changed files}

## Output Required
Return JSON:
{
  "verified_findings": [
    {
      "source": "gem-reviewer | se-security-reviewer",
      "severity": "BLOCKING | FOLLOW_UP | NICE_TO_HAVE",
      "location": "path/to/file.ts:42",
      "finding": "...",
      "suggestion": "..."
    }
  ],
  "removed_count": N,
  "removed_reasons": ["..."],
  "severity_adjustments": ["..."]
}
```

> `review-coordinator` â€” Phase 8 variant
```
You are being invoked as Review Coordinator for feature {feature-name} â€” Phase 8 (Code Review).

## Your Task
Synthesize all sub-agent outputs. Apply Phase 8 behavioral rules. Produce final routing verdict.

## Input
doublecheck output: {json â€” verified code + security findings}
janitor output: {json â€” cleanup items}
devils-advocate output: {json â€” failure scenarios}
knowledge-doc-auditor output: {json â€” docs completeness}

## Behavioral Rules to Enforce
- CRITICAL security finding = always blocking â†’ NEEDS_FIX â†’ Phase 4
- BLOCKING code finding = must fix before push â†’ NEEDS_FIX â†’ Phase 4
- Missing test coverage = must fix â†’ NEEDS_FIX â†’ Phase 7
- Docs incomplete = flag but not blocking (trigger lifecycle-scribe update)
- Apply CoT: walk each agent's output before concluding

## Output Required
Return JSON: {
  "verdict": "READY_TO_PUSH | NEEDS_FIX",
  "checklist": {
    "design_match": true|false,
    "no_logic_gaps": true|false,
    "security_addressed": true|false,
    "tests_cover_all": true|false,
    "docs_updated": true|false
  },
  "blocking_issues": [...],
  "route_to": "phase_4 | phase_7 | null"
}
```

---

## Output Contract (Phase-8 â†’ Orchestrator)

```json
{
  "verdict": "READY_TO_PUSH | NEEDS_FIX",
  "checklist": {
    "design_match": true,
    "no_logic_gaps": true,
    "security_addressed": true,
    "tests_cover_all": true,
    "docs_updated": true
  },
  "blocking_issues": [],
  "route_to": "phase_4 | phase_7 | null",
  "perf": {
    "context_budget_exceeded": 0,
    "started_at": "ISO-8601",
    "completed_at": "ISO-8601",
    "duration_ms": 10800,
    "tokens_input": 9200,
    "tokens_output": 1800,
    "tokens_total": 11000,
    "context_fill_rate": 0.046,
    "findings_raw": 9,
    "findings_after_filter": 6,
    "filter_ratio": 0.33,
    "must_fix_count": 0
  }
}
```

> Orchestrator writes `perf` block to `state.metrics.phase_8`. After this phase Orchestrator also computes and writes `state.metrics.totals`.

