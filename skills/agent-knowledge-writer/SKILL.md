---
name: agent-knowledge-writer
description: "Write or polish knowledge docs optimized for agent consumption. Adds When-to-Use sections, imperative instructions, explicit constraints, guardrails, JSON schema examples, and numbered workflows. Use when writing lifecycle phase docs, step docs, agent KS files, or any markdown read primarily by AI agents."
---

# agent-knowledge-writer

Write or polish markdown knowledge documents that AI agents read as Knowledge Sources. Human-readable docs are prose-first and explain "why". Agent-optimized docs are structure-first, imperative, and explicit — reducing hallucination by eliminating ambiguity.

## When to Use This Skill

Use when:
- Writing a new phase doc, step doc, or agent KS file
- Polishing existing docs that agents read from Knowledge Sources
- A doc feels "complete for humans" but may be ambiguous for an agent
- Adding a new lifecycle phase, review step, or pipeline stage
- Refactoring docs to reduce context size without losing precision

Keywords: agent-optimized, knowledge source, phase doc, step doc, lifecycle, agent-readable, machine-readable

## Core Principles

### 1. Imperative mood everywhere

Every instruction must be a direct command. No suggestions, no "should consider".

```
✅  "Return a JSON object with `verdict` and `perf` fields."
❌  "You might want to return some kind of JSON."
```

### 2. Explicit beats implicit

State constraints even when "obvious". An agent has no common sense — it only knows what is written.

```
✅  "Do NOT write to any file outside `{worktree_path}/`."
❌  "Stay in the worktree."
```

### 3. Structure over prose

Use numbered steps, headers, tables, and lists. Prose paragraphs cost tokens and reduce scan speed.

```
✅  Numbered workflow
    1. Read state file
    2. Invoke agent
    3. Write output

❌  "First you'll want to read the state file, then invoke the agent and write the output somewhere."
```

### 4. JSON schema as example, not description

Show the actual schema with example values. Never describe a JSON format in prose.

```
✅  
{
  "verdict": "APPROVED|NEEDS_REVISION",
  "confidence_score": 0.92,   // must be ≥ 0.85
  "gaps": ["gap 1"],
  "perf": {
    "duration_ms": 0,
    "tokens_total": 0,
    "tokens_input": 0,
    "context_fill_rate": 0,
    "context_budget_exceeded": false
  }
}

❌  "Return a JSON object that includes a verdict string, a confidence score, and a list of gaps."
```

### 5. When to Use section with trigger keywords

Every agent-consumed doc must include a `## When to Use` or `## Trigger Conditions` section. This enables the orchestrator or agent to decide whether to load the doc.

```markdown
## When to Use This Doc
Load this doc when:
- Current phase is Phase 3 (Design Review)
- `state.domain.has_frontend = true`
- Keywords: design review, BUI annotation, architecture critique
```

### 6. Guardrails over guidelines

State what MUST NOT happen, not just what SHOULD happen. Use all-caps keywords: MUST, NEVER, ONLY IF, ALWAYS, DO NOT.

```
✅  "NEVER skip Phase 6.5 regardless of active keywords."
✅  "ONLY invoke `bui-knowledge-builder` if `has_frontend = true`."
❌  "Try not to skip Phase 6.5 if you can."
```

### 7. Good/bad examples for output format

For every non-trivial output, show one correct and one incorrect example.

```markdown
### ✅ Correct
{ "verdict": "APPROVED", "confidence_score": 0.91 }

### ❌ Incorrect
{ "result": "ok" }   // missing required fields
```

### 8. Inline context budget

State the expected token budget for the doc inline. Helps orchestrator decide whether to pass full or summary.

```
> 📐 **Context budget:** ≤ 8 000 tokens. If diff exceeds budget, batch by subsystem.
```

## Workflow

### Step 1 — Audit existing doc (if polishing)

For each section, check:
- [ ] Is prose convertible to a numbered list or table?
- [ ] Are all instructions in imperative mood?
- [ ] Are all constraints explicit (MUST/NEVER)?
- [ ] Does a JSON schema exist as code block (not prose)?
- [ ] Is there a "When to Use" section?
- [ ] Are there any "good/bad" output examples?

### Step 2 — Write / patch

Apply only what's missing or wrong. Do NOT rewrite sections that already pass the audit. Surgical changes only.

Priority order (highest value per token saved):
1. Add `## When to Use` if missing
2. Convert prose instructions to numbered steps
3. Replace JSON-in-prose with actual code block schema
4. Add MUST/NEVER guardrails
5. Add good/bad examples

### Step 3 — Validate

- No prose instructions remain where numbered steps work better
- All JSON output examples are valid JSON (or JSONC with inline comments)
- "When to Use" section exists and has trigger keywords
- Constraints use MUST/NEVER/ONLY IF, not "should" or "might"
- Doc size ≤ 400 lines (if longer, split into summary + detail)

## Anti-Patterns

- ❌ Prose-only constraint: "Be careful not to overload the context" → MUST: trim context to budget before passing
- ❌ "Return JSON" without schema → always show the schema
- ❌ Implicit trigger: no When-to-Use → orchestrator may load wrong doc or miss the right one
- ❌ Passive voice: "The output should be verified" → "Verify output before returning"
- ❌ Vague guardrail: "try not to" → use NEVER
- ❌ Bloated doc: >400 lines of inline context → split, reference sub-sections

## Output

Return the patched file(s). For each file changed, note:
- Sections added
- Lines converted (prose → steps / prose → schema)
- Guardrails added

