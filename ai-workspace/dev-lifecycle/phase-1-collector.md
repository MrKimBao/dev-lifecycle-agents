# Phase 1 â€” Collector

> **Status:** âœ… Done  
> **Part of:** [dev-lifecycle-guide.md](./dev-lifecycle-guide.md)

---

## When to Use This Doc

Load when:
- Orchestrator is starting Phase 1 (new feature / Epic / Story)
- Phase 2 returns `NEEDS_REVISION` and Phase 1 must revise with gap list
- `requirement-intake` agent is about to be invoked

> ðŸ“ **Context budget:** â‰¤ 8 000 tokens.

Keywords: collector, requirement intake, epic, user story, DoR, INVEST, domain knowledge check, requirement-intake

---

## Overview

**Persona:** Curious, methodical, thorough. Assumes nothing. Asks until the picture is complete.

**Primary goal:** Bootstrap a new feature from a Jira Epic or User Story â€” validate, gather requirements, produce design draft, and write the 3 required docs (`requirements`, `design`, `planning`).

**Single entry point:** `requirement-intake` agent (Hybrid Coordinator) â€” called once by Orchestrator, handles everything internally.

**Exit condition:** 3 docs written to disk + JSON contract returned to Orchestrator. Or `dor_failed` if DoR gate not passed.

---

## Internal Agent Pipeline

```mermaid
flowchart LR
    classDef agent   fill:#475569,stroke:#334155,color:#fff
    classDef gate    fill:#f59e0b,stroke:#b45309,color:#000
    classDef stop    fill:#ef4444,stroke:#991b1b,color:#fff
    classDef done    fill:#22c55e,stroke:#15803d,color:#fff
    classDef warn    fill:#f97316,stroke:#c2410c,color:#fff

    IN([User ticket]) --> A1
    A1[knowledge-doc-auditor\ndomain check]:::agent --> STALE{stale?}
    STALE -->|missing docs| SPIKE[add spike task\ncontinue]:::warn
    STALE -->|stale docs| ESC([âš ï¸ Escalate to user\nSTOP]):::stop
    STALE -->|ok| A2
    SPIKE --> A2
    A2{DoR gate}:::gate -->|fail| STOP([Return to PO]):::stop
    A2 -->|pass| A3
    A3[requirement-intake\ngather + enrich]:::agent --> A4
    A4[bui-knowledge-builder]:::agent --> A5
    A5[gem-researcher]:::agent --> A6
    A6[gem-designer\ndraft only]:::agent --> A7
    A7[gem-documentation-writer]:::agent --> OUT([3 docs to Orchestrator]):::done
```

---

## Input Types

| Type | Flow |
|------|------|
| **Epic** | Validate outcome-based â†’ break into child stories (INVEST per story) â†’ run Phase 1 per story |
| **User Story** | Validate well-formed â†’ INVEST check â†’ DoR gate â†’ gather â†’ enrich â†’ design draft â†’ write docs |

---

## Steps

1. **Parse ticket** â€” extract: ID, type (Epic/Story), summary, description, existing AC, labels (all provided by user)
2. **Domain knowledge check** â€” delegate `knowledge-doc-auditor` to scan `docs/ai/domain-knowledge/` + memory; flag missing or stale coverage:
   - **Missing docs** â†’ add knowledge spike task to planning
   - **Stale docs** â†’ return `knowledge_stale` status to orchestrator â†’ orchestrator escalates to user (run `update knowledge for X` first)
3. **Validate ticket quality**
   - Epic: outcome-based (not solution-prescriptive)? Clear success metrics?
   - Story: **INVEST** check (Independent, Negotiable, Valuable, Estimable, Small, Testable)
4. **DoR gate** â€” must pass before any design work:
   - [ ] Clear problem statement
   - [ ] Target users identified
   - [ ] At least 1 measurable success criterion (no "fast", "good UX", "scalable")
   - [ ] No unresolved external blockers
   - [ ] Estimable â€” spike task added if unknowns exist
5. **Epic â†’ Story breakdown** *(Epic only)* â€” use domain knowledge + INVEST; each child story must pass DoR independently
6. **Gather requirements** â€” ReAct loop: ask user 1 topic at a time; cover problem, JTBD, user stories (As a / I want / So that), success criteria, out-of-scope, constraints
7. **Enrich requirements** â€” for each story: AC (Given/When/Then), Technical Considerations, Edge Cases, NFRs
8. **Design first draft** â€” delegate: `bui-knowledge-builder` â†’ `gem-researcher` â†’ `gem-designer` (draft only â€” Phase 3 does full architectural review)
9. **Write docs** â€” delegate: `gem-documentation-writer` â†’ creates `requirements.md`, `design.md`, `planning.md`

**Gates:**
- âš ï¸ DoR not met â†’ `status: dor_failed`, return issues to PO, STOP immediately
- âš ï¸ Knowledge gap found â†’ add spike task to planning doc, continue

**Non-negotiable constraints:**
- MUST check `docs/ai/domain-knowledge/` + memory BEFORE asking the user anything
- MUST ask ONE topic at a time â€” NEVER dump a list of questions
- MUST pass DoR gate before any design work begins
- NEVER fill gaps with assumptions â€” mark every unknown as `[TBD]`
- NEVER design an Epic directly â€” ALWAYS break into stories first

---

## ðŸ¤– Custom Agent: `requirement-intake`

> **Design pattern: Hybrid Coordinator**  
> Owns requirements gathering + enrichment internally. Delegates only design and doc creation to specialists.  
> Orchestrator calls **1 agent**, not 5 in sequence.

**Agent file:** `.github/agents/requirement-intake.agent.md`  
**Recommended model:** `claude-sonnet-4.5` (reasoning + speed balance)

**Why custom instead of raw sub-agents?**
- Epic/Story branching + INVEST + DoR + AC enrichment all live inside one session
- Domain knowledge check is deterministic â€” focused coordinator, not generic agent
- Context is preserved across all sub-steps without passing state through Orchestrator

---

### ðŸŽ­ Persona

Behaves like a senior Product Manager who has read every existing feature in the codebase.  
Never asks what the team already knows. Never fills gaps with assumptions.  
Every open question gets explicitly flagged as `[TBD]`.

---

### ðŸ§  Reasoning Techniques

| Context | Technique | How |
|---------|-----------|-----|
| Opening a new ticket | âš›ï¸ **ReAct** | Think â†’ Ask user 1 question â†’ Observe â†’ Re-think. Loop until all sections covered. |
| Structuring requirements | ðŸ”— **Chain-of-Thought** | Walk each section: problem â†’ goals â†’ users â†’ stories â†’ constraints â†’ success criteria |
| Architecture draft | ðŸŒ³ **Tree of Thoughts** | Explore 3 design directions. For each: pros, cons, fatal flaw. Pick winner before filling design doc. |
| Domain + memory lookup | âš›ï¸ **ReAct** | Search `docs/ai/domain-knowledge/` + memory â†’ apply matches â†’ only ask about uncovered gaps |
| Breaking Epic into Stories | ðŸ“‰ **Least-to-Most** | Start with simplest, most independent story. Build up only after each story passes INVEST. |

---

### âš™ï¸ Agent Configuration

**Tools to enable:**
```yaml
tools:
  - read_file          # read domain-knowledge docs + templates
  - write_file         # create docs/ai/ files
  - memory_search      # find past conventions
  - memory_store       # save clarifications
  - search_codebase    # find existing patterns before designing
  - run_agent          # delegate to gem-researcher, gem-designer, gem-documentation-writer
```

**Internal state machine:**
```
INIT
 â”‚
 â–¼
PARSE_TICKET          â†’ id, type, summary, description, AC, links
 â”‚
 â–¼
DOMAIN_CHECK          â†’ delegate: knowledge-doc-auditor â†’ scan docs/ai/domain-knowledge/ + memory
 â”œâ”€ missing docs  â†’ add spike task to planning, continue
 â””â”€ stale docs    â†’ return knowledge_stale â†’ orchestrator escalates to user (STOP)
 â”‚
 â–¼
CLASSIFY
 â”œâ”€ Epic  â†’ VALIDATE_EPIC â†’ BREAK_INTO_STORIES (INVEST per story) â†’ loop per story
 â””â”€ Story â†’ INVEST_CHECK â†’ DoR_GATE
                               â”‚
                           DoR FAIL â†’ return to PO (stop, list issues)
                           DoR PASS â†“
 â–¼
GATHER_REQUIREMENTS   â†’ ReAct loop: 1 question at a time
 â”‚                       problem Â· JTBD Â· users Â· stories Â· success criteria Â· out-of-scope Â· constraints
 â–¼
ENRICH_REQUIREMENTS   â†’ AC (Given/When/Then) Â· Tech Considerations Â· Edge Cases Â· NFRs Â· dup check
 â”‚
 â–¼
DESIGN_DRAFT          â†’ delegate: bui-knowledge-builder â†’ gem-researcher â†’ gem-designer (DRAFT ONLY)
 â”‚
 â–¼
WRITE_DOCS            â†’ delegate: gem-documentation-writer (CREATE from scratch)
 â”‚
 â–¼
OUTPUT_JSON           â†’ return contract to Orchestrator
```

---

### ðŸ“‹ System Prompt (`.agent.md` key sections)

```markdown
## Role
You are Requirement Intake â€” the entry point for all new feature requests.
You own requirements gathering + enrichment, then coordinate design draft
and doc creation with specialist sub-agents.

## Persona
Curious, methodical, thorough. Assumes nothing.
Never asks what the team already knows. Never fills gaps with assumptions.
Mark every unknown as [TBD].

## Reasoning Techniques
- ReAct: Think â†’ Ask 1 question â†’ Observe â†’ Re-think. Use for requirements gathering.
- Chain-of-Thought: Walk each doc section explicitly. Use for structuring requirements.
- Tree of Thoughts: 3 design directions before committing. Use for design draft.
- Least-to-Most: Simplest story first when breaking Epics.

## Rules
- Always check docs/ai/domain-knowledge/ + memory BEFORE asking the user anything
- Ask ONE topic at a time â€” never dump a list of questions
- Validate INVEST + DoR before any design work
- For Epics: break into stories first; never design an Epic directly
- Enrich every story with AC, edge cases, NFRs before design
- All doc content in English only
- Output the standardized JSON contract when done

## DoR Checklist (must pass before design)
- [ ] Clear problem statement
- [ ] Target users identified with JTBD framing
- [ ] At least 1 measurable success criterion
- [ ] No unresolved external blockers
- [ ] Estimable (spike task added if unknowns exist)

## INVEST (apply to each Story)
- Independent Â· Negotiable Â· Valuable Â· Estimable Â· Small Â· Testable
```

---

### ðŸ“¤ Invocation Prompt (Orchestrator â†’ `requirement-intake`)

```
You are being invoked as Requirement Intake for a new feature request.

## Your Task
Process this ticket end-to-end: validate, gather requirements, enrich stories,
produce design draft, and write the 3 required docs (requirements + design + planning).

## Input
Ticket type: {Epic | Story}
Ticket ID: {provided by user}
Summary: {title}
Description: {full description}
Existing AC: {if any}
Dependencies / linked tickets: {provided by user if any}
Domain knowledge path: docs/ai/domain-knowledge/
Feature name (kebab-case): {feature-name}
Git branch: {created by user â€” use as-is}

## Output Required
3 docs written to disk + return JSON:
{
  "status": "done | dor_failed | needs_user_input",
  "feature": "{name}",
  "ticket_type": "epic | story",
  "child_stories": [...],     // only if Epic
  "dor_issues": [...],        // only if dor_failed
  "spike_tasks": [...],       // flagged unknowns
  "docs": {
    "requirements": "docs/ai/requirements/feature-{name}.md",
    "design": "docs/ai/design/feature-{name}.md",
    "planning": "docs/ai/planning/feature-{name}.md"
  },
  "summary": "plain-text summary"
}

## Constraints
- DoR not met â†’ status = "dor_failed", list issues, stop
- Knowledge gap â†’ add spike task to planning, continue
- All doc content in English only
- Ask one question at a time
```

---

### ðŸ¤– Sub-agents Delegated by `requirement-intake`

| Role | Agent | Status | Scope | Note |
|------|-------|--------|-------|------|
| **Domain knowledge check** | `knowledge-doc-auditor` | âœ… Installed | Audit `docs/ai/domain-knowledge/` for coverage gaps before design | Missing â†’ spike task added. Stale â†’ return `knowledge_stale` â†’ orchestrator escalates to user |
| **BUI component catalog** | `bui-knowledge-builder` | âœ… Installed | Crawl ui.backstage.io â†’ build fresh BUI component catalog | Run before `gem-designer` â€” ensures design uses latest BUI components |
| **Codebase context** | `gem-researcher` | âœ… Installed | Find existing patterns before design draft | Called after `bui-knowledge-builder`, before `gem-designer` |
| **Design first draft** | `gem-designer` | âœ… Installed | Mermaid + data model + API sketch â€” **DRAFT ONLY** | Consumes BUI catalog + codebase context. Phase 3 does full review |
| **Doc creation** | `gem-documentation-writer` | âœ… Installed | **CREATE** new docs from scratch | Phase 1 only â€” not for updates |

---

## Output Contract (Phase-1 â†’ Orchestrator)

```json
{
  "status": "done | dor_failed | needs_user_input",
  "feature": "feature-name",
  "ticket_type": "epic | story",
  "child_stories": [],
  "dor_issues": [],
  "spike_tasks": [],
  "docs": {
    "requirements": "docs/ai/requirements/feature-name.md",
    "design": "docs/ai/design/feature-name.md",
    "planning": "docs/ai/planning/feature-name.md"
  },
  "summary": "Short plain-text summary of what was captured",
  "perf": {
    "started_at": "ISO-8601",
    "completed_at": "ISO-8601",
    "duration_ms": 18400,
    "tokens_input": 8200,
    "tokens_output": 2400,
    "tokens_total": 24600,
    "context_fill_rate": 0.041,
    "context_budget_exceeded": false,
    "questions_asked": 7,
    "dor_result": "pass | fail",
    "spike_tasks_added": 1
  }
}
```

> Orchestrator writes `perf` block to `state.metrics.phase_1` immediately on receiving the output.

