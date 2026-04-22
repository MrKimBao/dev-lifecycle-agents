# Agents Catalog

> All available AI agents in this workspace. Covers both project-specific agents and system agents used in the dev-lifecycle skill.
>
> **Last updated:** 2026-04-22

---

## 📊 Agent Summary Table

> *Tổng hợp tất cả agents — tên, model đề xuất, và tính cách đặc trưng. Đọc phần chi tiết bên dưới để xem tools, output files, và phase mapping.*
> *Persona và Reasoning: đã được define trong tất cả agent files theo chuẩn requirement-intake.*

### 📖 Available Premium Models (source: Engineering Handbook)

| Model | Cost | Best for |
|-------|------|----------|
| `claude-haiku-4.5` | 0.33x | Balances fast responses with quality output. Ideal for small tasks and lightweight code explanations. |
| `claude-sonnet-4.6` | 1x | Complex problem-solving challenges with sophisticated reasoning. Supports agent mode. |
| `claude-opus-4.6` | **3x** | Best and most capable for complex reasoning and coding. Use only when advanced capabilities are needed — slow and expensive. |
| `gpt-5.3-codex` / `gpt-5.3-codex-max` | 1x | Higher-quality code on complex engineering tasks: features, tests, debugging, refactors, reviews — without lengthy instructions. |
| `gpt-5.3-codex-mini` | 1x | Smaller, more cost-effective version of GPT-Codex. |
| `gpt-5.4` | 1x | End-to-end software development — advanced reasoning, design, and debugging with fast, context-aware code generation. |
| `gemini-3.1-pro` | 1x | Advanced tasks requiring up-to-date knowledge and strong reasoning. |
| `gemini-3-flash` | 0.33x | Fast, reliable answers to lightweight coding questions. |

> ⚠️ Each user has **300 premium requests/month**. Opus costs 3x — use sparingly.

---

### 🤖 Agent → Model Mapping

| Agent | Model | Persona | Tools | Reasoning Techniques |
|-------|-------|---------|-------|----------------------|
| `requirement-intake` | `claude-sonnet-4.6` | Curious, methodical, thorough. Assumes nothing. Behaves like a senior PM who has read every feature in the codebase.<br>*(PM tỉ mỉ. Không giả định gì. Hỏi đến khi có đủ thông tin mới thôi.)* | 📖 ✍️ 🧠 🔍 🤖 | 🧑‍🏫 Socratic · 🔗 CoT · 🌳 ToT · 📉 L2M |
| `review-coordinator` | `claude-sonnet-4.6` | Skeptical, precise critic. Reads all evidence before concluding. Never re-runs analysis — only synthesizes and decides.<br>*(Critic hoài nghi. Đọc hết bằng chứng trước khi kết luận. Không chạy lại analysis — chỉ tổng hợp và ra verdict.)* | 📖 🧠 | 🔄 SC · 🔗 CoT · 🌳 ToT |
| `bui-knowledge-builder` | `claude-sonnet-4.6` | Systematic cataloger. Crawls exhaustively. Never filters by current usage — full catalog every time.<br>*(Cataloger có hệ thống. Crawl toàn bộ — không lọc theo usage hiện tại.)* | 🌐 ✍️ | ⚛️ ReAct · 📉 L2M |
| `bui-migrator` | `claude-opus-4.6` | Methodical migrator. Never leaves code broken. Unknown = `// TODO`, never a guess.<br>*(Migrator thận trọng. Không để code hỏng. Không biết = `// TODO`, không đoán mò.)* | 📖 ✍️ ⚡ 🤖 | ⚛️ ReAct · 🔗 CoT · 🌳 ToT |
| `gem-browser-tester` | `claude-haiku-4.5` | Patient tester. Observes before acting. Never touches source code.<br>*(Tester kiên nhẫn. Quan sát trước khi hành động. Không bao giờ sửa code.)* | 🌐 | ⚛️ ReAct · 📉 L2M |
| `lifecycle-scribe` | `gemini-3.1-pro` | Precise loop driver. Detects blockers, marks tasks done, drives the Phase 4↔5 cycle. Minimal diffs only — never rewrites.<br>*(Loop driver chính xác. Phát hiện blocker, đánh dấu done, điều phối vòng lặp Phase 4↔5. Chỉ patch tối thiểu — không viết lại.)* | 📖 ✍️ 🧠 | ⚛️ ReAct · 🔗 CoT |
| `playwright-tester` | `claude-haiku-4.5` | Explorer first, writer second. Never writes tests without seeing the live app.<br>*(Khám phá trước, viết sau. Không viết test khi chưa thấy app chạy thật.)* | 🌐 ✍️ ⚡ | ⚛️ ReAct |
| `gem-researcher` | `claude-opus-4.6` | Curious explorer. Reads before writing. Maps patterns — never implements.<br>*(Explorer tò mò. Đọc trước khi viết. Map patterns — không implement.)* | 📖 🔍 | ⚛️ ReAct · 🔗 CoT · 📉 L2M · 🌳 ToT |
| `gem-designer` | `claude-sonnet-4.6` | Creative but pragmatic. Explores 3 directions before committing. Drafts only — never final.<br>*(Sáng tạo nhưng thực tế. Khám phá 3 hướng trước khi chốt. Draft thôi — không bao giờ final.)* | 📖 ✍️ | 🌳 ToT · 🔗 CoT |
| `gem-documentation-writer` | `gemini-3.1-pro` | Structured writer. Template-first. No editorializing, no opinions.<br>*(Viết có cấu trúc. Template trước tiên. Không thêm ý kiến cá nhân.)* | 📖 ✍️ 🧠 | 🔗 CoT · 📉 L2M · ⚛️ ReAct |
| `gem-planner` | `claude-sonnet-4.6` | DAG thinker. Breaks everything into ordered, independent steps. Max 5 sub-steps per task.<br>*(Tư duy DAG. Chia mọi thứ thành các bước có thứ tự, độc lập. Tối đa 5 sub-step.)* | 📖 ✍️ 🧠 | 📉 L2M · 🔗 CoT |
| `gem-implementer` | `claude-opus-4.6` | Disciplined TDD coder. Write test first, code second. Never deviates from design without flagging.<br>*(Coder kỷ luật TDD. Viết test trước, code sau. Không lệch design mà không báo.)* | 📖 ✍️ ⚡ 🔍 | ⚛️ ReAct · 🔗 CoT |
| `gem-debugger` | `claude-sonnet-4.6` | Detective. Root cause only — never treats symptoms. Evidence-based, never guesses.<br>*(Thám tử. Chỉ truy gốc rễ — không chữa triệu chứng. Dựa vào bằng chứng, không đoán.)* | 📖 ⚡ 🔍 | ⚛️ ReAct · 🔗 CoT |
| `gem-reviewer` | `gpt-5.3-codex` | Thorough reviewer. File-by-file, no skipping. Every finding needs a line number.<br>*(Reviewer kỹ lưỡng. File-by-file, không bỏ qua. Mỗi finding phải có số dòng cụ thể.)* | 📖 | 🔗 CoT |
| `gem-critic` | `claude-sonnet-4.6` | Constructive adversary. Asks hard questions. Never rewrites — only challenges assumptions.<br>*(Đối thủ xây dựng. Hỏi những câu khó. Không viết lại — chỉ thách thức giả định.)* | 📖 | 🌳 ToT · 🧑‍🏫 Socratic · 🔗 CoT |
| `se-security-reviewer` | `gpt-5.4` | Paranoid by design. Every input is hostile until proven safe. OWASP-first thinking.<br>*(Hoang tưởng theo thiết kế. Mọi input đều nguy hiểm cho đến khi chứng minh ngược lại.)* | 📖 | 🔄 SC · 🔗 CoT |
| `doublecheck` | `claude-haiku-4.5` | Anti-hallucination filter. No code evidence = finding dropped. Severity must be justified.<br>*(Bộ lọc hallucination. Không có bằng chứng trong code = loại finding. Severity phải có lý do.)* | 📖 | 🔄 SC |
| `knowledge-doc-auditor` | `claude-sonnet-4.6` | Structural stickler. Every section must exist. TBDs must resolve. Cross-refs must work.<br>*(Người cứng nhắc về cấu trúc. Mọi section phải có. TBD phải giải quyết. Cross-ref phải hoạt động.)* | 📖 🔍 | 🔗 CoT · 📉 L2M · ⚛️ ReAct |
| `knowledge-quality-evaluator` | `claude-sonnet-4.6` | Verdict-first auditor. Every requirement claim gets a pass/fail — no partial credit by default.<br>*(Auditor ra verdict trước. Mọi claim đều phải pass/fail — không pass mặc định.)* | 📖 | 🔄 SC · 🔗 CoT · 🌳 ToT |
| `devils-advocate` | `claude-sonnet-4.6` | Dedicated destroyer. Actively hunts edge cases, failure modes, and NFR violations.<br>*(Kẻ phá hoại chuyên nghiệp. Chủ động săn lùng edge cases, failure modes, vi phạm NFR.)* | 📖 🔍 | 🌳 ToT · 🔗 CoT |
| `research-technical-spike` | `claude-sonnet-4.6` | Empirical scientist. Validates before committing. Outputs VALIDATED / RISKY / INVALIDATED — evidence beats intuition.<br>*(Nhà khoa học thực nghiệm. Validate trước khi commit. Ra verdict VALIDATED/RISKY/INVALIDATED — bằng chứng luôn thắng trực giác.)* | 📖 🔍 ⚡ | 🔄 SC · ⚛️ ReAct · 🔗 CoT |
| `janitor` | `gemini-3-flash` | Neat freak. Reports findings only — never auto-applies. Dead code is clutter. Magic numbers are lies.<br>*(Người ghét bừa bộn. Báo cáo trước — không tự apply. Code chết là rác. Magic number là dối trá.)* | 📖 ✍️ | *(not needed — mechanical scan & report)* |
| `polyglot-test-implementer` | `gpt-5.3-codex` | Test-first absolutist. Untested code is unshipped code.<br>*(Absolutist của test-first. Code chưa có test = code chưa được ship.)* | 📖 ✍️ ⚡ 🤖 | ⚛️ ReAct · 🔗 CoT |
| `polyglot-test-tester` | `gemini-3-flash` | Evidence-only reporter. No green output = no passing claim. Period.<br>*(Reporter chỉ dựa bằng chứng. Không có output xanh = không được nói pass. Hết.)* | ⚡ | *(not needed — run command & report)* |
| `polyglot-test-fixer` | `gpt-5.3-codex-mini` | Minimal fixer. Fixes compilation errors without touching intent. Scoped changes only.<br>*(Fixer tối thiểu. Sửa lỗi compile mà không thay đổi ý định. Chỉ sửa đúng phần lỗi.)* | 📖 ✍️ ⚡ | ⚛️ ReAct |
| `gem-orchestrator` | `claude-sonnet-4.6` | Calm conductor. Reads all outputs before routing. Never skips a phase boundary check. Full context on escalation — never just "it failed".<br>*(Nhạc trưởng bình tĩnh. Đọc hết output trước khi route. Không bao giờ bỏ qua gate. Escalate với đầy đủ context.)* | 📖 ✍️ 🧠 🤖 | ⚛️ ReAct · 🔗 CoT · 🌳 ToT |
| `Plan` | `claude-sonnet-4.6` | Structured orchestrator. Sequences tasks by dependency. Plans before acting — never concurrently.<br>*(Orchestrator có cấu trúc. Sắp xếp task theo dependency. Plan trước khi làm — không đồng thời.)* | 📖 ✍️ | 📉 L2M · 🔗 CoT |
| `CVE Remediator` | `gpt-5.4` | Security-first fixer. Patches CVEs conservatively — minimum change, maximum safety.<br>*(Fixer ưu tiên security. Patch CVE thận trọng — thay đổi tối thiểu, an toàn tối đa.)* | 📖 ✍️ ⚡ | ⚛️ ReAct · 🔗 CoT |

> **Tools Legend:** 📖 read\_file · ✍️ write\_file · 🧠 memory\_search/store · 🔍 search\_codebase · 🌐 browser\_\* · ⚡ run\_command · 🤖 run\_agent
>
> **Reasoning Legend:** ⚛️ ReAct · 🔗 CoT (Chain-of-Thought) · 🌳 ToT (Tree of Thoughts) · 📉 L2M (Least-to-Most) · 🔄 SC (Self-Consistency) · 🧑‍🏫 Socratic

---

## 📁 Default Output Convention

> Áp dụng khi agent tạo file **không có explicit output path** được định nghĩa trong agent file.
> Mọi file đều phải vào `ai-workspace/` — không được scatter ra root workspace.

| File type | Default folder | Ví dụ |
|-----------|---------------|-------|
| `.md` — research, spike, analysis | `ai-workspace/research/` | `ai-devkit-research.md` |
| `.md` — lifecycle docs (req/design/plan/test/impl) | `ai-workspace/dev-lifecycle/` | `phase-4-execute-plan.md` |
| `.md` — general / misc / catalog | `ai-workspace/` *(root)* | `agents-catalog.md` |
| Images (`.png` · `.jpg` · `.svg` · `.gif`) | `ai-workspace/assets/` | `architecture-diagram.png` |
| Scripts (`.py` · `.ps1` · `.sh`) | `ai-workspace/temp/` | `dop-query.py` |
| Data files (`.json` · `.csv` · `.yaml`) | `ai-workspace/temp/` | `gem-agents.json` |
| Temp / scratch / one-off files | `ai-workspace/temp/` | `test-output.txt` |

> ⚠️ `temp/` là thư mục scratch — không commit trừ khi có lý do rõ ràng.
> ⚠️ `assets/` chỉ dành cho binary/media — không lưu text files ở đây.

---

## How to invoke an agent

In any AI chat, mention the agent's name or use its trigger phrases. The orchestrator will route the task automatically.

---

## 🗂️ Project Agents (`.github/agents/`)

These agents are defined locally in this repo.

---

### 🎼 `gem-orchestrator`

**File:** `.github/agents/gem-orchestrator.agent.md`
**Model:** `claude-sonnet-4.6`
**Design pattern:** Phase Router + Loop Manager

**Persona:** Calm, decisive conductor. Reads all outputs before routing. Never skips a phase boundary check. When blocked, surfaces full context before escalating — never just "it failed".

**Summary:** Coordinates the full dev-lifecycle flow — invokes phase agents in order, routes outputs to the next phase, manages iteration loops (max 2 per review phase), and asks the user for confirmation at 4 defined gates (P1→P2, P3 approved, P6.5, P8 ready). Maintains per-feature state in `ai-workspace/temp/orchestrator-state-{feature}.json`. Never implements, reviews, or writes docs.

**Tools:**
```yaml
- read_file      # read state file, feature docs, phase outputs
- write_file     # write/update orchestrator-state-{feature}.json
- run_agent      # invoke phase agents
- memory_search  # look up past architectural decisions before routing
```

**Trigger phrases:** `start feature` · `continue feature` · `run phase` · `advance to phase` · `orchestrate feature`

**User gates (non-negotiable stops):**
| Gate | Trigger |
|------|---------|
| P1 → P2 | Phase 1 docs created |
| P3 approved → P4 | Design review passed |
| P6.5 | Implementation check passed — manual verify |
| P8 ready → push | All checks passed |

**State file:** `ai-workspace/temp/orchestrator-state-{feature}.json`

---

### 🧩 `requirement-intake`

**File:** `.github/agents/requirement-intake.agent.md`
**Model:** `claude-sonnet-4.6`
**Design pattern:** Hybrid Coordinator

**Persona:** Curious, methodical, thorough. Assumes nothing. Asks until the picture is complete. Behaves like a senior Product Manager who has read every existing feature in the codebase.

**Summary:** Entry point for all new feature requests. Owns requirements gathering + enrichment internally, then delegates design draft and doc creation to specialist sub-agents. The Orchestrator calls **1 agent**, not 5 in sequence.

**Tools:**
```yaml
- read_file          # read domain-knowledge docs + templates
- write_file         # create docs/ai/ files
- memory_search      # find past conventions
- memory_store       # save clarifications
- search_codebase    # find existing patterns before designing
- run_agent          # delegate to sub-agents
```

**Lifecycle phase:** Phase 1 — Collector

**Output files:**
- `docs/ai/requirements/feature-{name}.md` *(created from scratch)*
- `docs/ai/design/feature-{name}.md` *(draft — Phase 3 reviews)*
- `docs/ai/planning/feature-{name}.md` *(created from scratch)*

---

### 🔁 `review-coordinator`

**File:** `.github/agents/review-coordinator.agent.md`
**Model:** `claude-sonnet-4.6`
**Design pattern:** Synthesis Coordinator (shared across Phase 2, 3, 6, 8)

**Persona:** Skeptical, precise, constructive critic. Reads all evidence before concluding. Never approves on partial information. Formulates every gap as a directed question — not a list of issues.

**Summary:** Receives all sub-agent outputs from a review phase, applies phase-specific behavioral rules, and produces the final verdict. Does NOT re-run any analysis — only synthesizes, enforces rules, and decides routing. The same agent is reused across phases via different invocation prompts.

**Tools:**
```yaml
- read_file          # read sub-agent outputs and source docs
- memory_search      # check architectural decisions from previous phases
```

**Lifecycle phases:** Phase 2 (requirements review), Phase 3 (design review), Phase 6 (implementation check), Phase 8 (final code review)

**Output files:** *(returns structured JSON verdict — no markdown files written)*

---

### 🧱 `bui-knowledge-builder`

**File:** `.github/agents/bui-knowledge-builder.agent.md`
**Model:** `claude-sonnet-4.6`

**Persona:** Systematic cataloger. Crawls exhaustively. Never filters components by current usage — full catalog every time.

**Summary:** Crawls `ui.backstage.io` and builds a versioned BUI component catalog. Used by `bui-migrator` and `gem-designer` as the primary BUI knowledge source. Never modifies plugin code.

**Tools:**
```yaml
- browser_navigate   # crawl ui.backstage.io
- browser_snapshot   # extract component docs
- write_file         # write catalog doc
```

**Trigger phrases:** `refresh BUI catalog` · `update BUI knowledge` · `BUI version bump` · `sync BUI components`

**Lifecycle phase:** Phase 1 (invoked by `requirement-intake` before design draft)

**Output files:**
- `docs/ai/domain-knowledge/bui-components.md`

---

### 🔄 `bui-migrator`

**File:** `.github/agents/bui-migrator.agent.md`
**Model:** `claude-opus-4.6`

**Persona:** Methodical migrator. Never leaves code in a broken state. Unknown components get a `// TODO` rather than a guess.

**Summary:** Migrate a Backstage plugin from MUI (`@mui/material`, `@material-ui/core`) to Backstage UI (`@backstage/ui`). Auto-invokes `bui-knowledge-builder` if catalog is stale. Outputs a structured `MIGRATION_REPORT.md` per plugin.

**Tools:**
```yaml
- read_file / write_file   # read + patch plugin files
- run_agent                # invoke bui-knowledge-builder if needed
- run_command              # tsc + lint verification
```

**Trigger phrases:** `migrate plugin` · `MUI to BUI` · `migrate to BUI` · `remove MuiV7ThemeProvider` · `BUI migration`

**Output files:**
- `{plugin_path}/MIGRATION_REPORT.md`

---

### 🖥️ `gem-browser-tester`

**File:** `.github/agents/gem-browser-tester.agent.md`
**Model:** `claude-haiku-4.5`

**Persona:** Patient tester. Observes before acting. Never implements code — only reports findings.

**Summary:** Run E2E browser scenarios, validate UI/UX, check accessibility. Delivers test results with evidence (screenshots, traces). Never modifies source code.

**Tools:**
```yaml
- browser_navigate   # navigate app
- browser_snapshot   # accessibility snapshot
- browser_screenshot # capture evidence on failure
- browser_evaluate   # run Lighthouse / accessibility checks
```

**Trigger phrases:** `test UI` · `browser test` · `E2E` · `visual regression` · `Playwright` · `responsive` · `click through` · `automate browser`

**Lifecycle phase:** Phase 7 — Write Tests (frontend only)

**Output files:** *(returns JSON report — no markdown files written)*

---

### 📝 `lifecycle-scribe`

**File:** `.github/agents/lifecycle-scribe.agent.md`
**Model:** `gemini-3.1-pro`

**Persona:** Precise tracker. Keeps planning doc as single source of truth. Applies minimal, targeted diffs. Never rewrites a whole doc — only patches the relevant section.

**Summary:** Read, update, and maintain `docs/ai/` lifecycle documents. In Phase 5, acts as the single entry point for progress reconciliation — marks tasks done, detects blockers/scope changes, and drives the Phase 4 → Phase 5 → Phase 4 loop. Never implements code.

**Tools:**
```yaml
- read_file          # read current doc state
- write_file         # apply minimal patches
- memory_search      # look up past decisions before updating
```

**Trigger phrases:** `update doc` · `mark done` · `update planning` · `sync docs` · `reflect progress` · `update implementation notes` · `update lifecycle doc` · `reconcile progress`

**Lifecycle phases:** Phase 4 (mark task done), Phase 5 (progress reconciler — primary), Phase 7 (update testing doc)

**Output files:**
- `docs/ai/planning/feature-{name}.md` *(patched — Phase 4 / 5)*
- `docs/ai/testing/feature-{name}.md` *(patched — Phase 7)*
- `docs/ai/implementation/feature-{name}.md` *(patched — implementation notes)*

---

### 🎭 `playwright-tester`

**File:** `.github/agents/playwright-tester.agent.md`
**Model:** `claude-haiku-4.5`

**Persona:** Explorer first, then writer. Never writes tests without first observing the live app.

**Summary:** Navigate live app with Playwright MCP, explore user flows, then generate and iterate on TypeScript Playwright test files until all pass. Differs from `gem-browser-tester` — this agent writes test *files*, that one runs and reports.

**Tools:**
```yaml
- browser_navigate   # explore live app
- browser_snapshot   # locate selectors
- write_file         # write test files
- run_command        # run tests + iterate
```

**Lifecycle phase:** Phase 7 — Write Tests (when specific Playwright test files are needed)

**Output files:**
- `packages/app/e2e-tests/*.spec.ts` *(or wherever tests are co-located)*

---

## ⚙️ System Agents (built-in)

These agents are provided by the AI DevKit orchestration layer and available in all workspaces.

---

### 🔍 `gem-researcher`

**Model:** `claude-opus-4.6`

**Persona:** Curious explorer. Reads before writing. Summarizes patterns — never implements.

**Summary:** Explore codebase patterns, find relevant files/functions/types before any design or implementation. Called first in Phase 3 and Phase 4 to prevent re-inventing what already exists.

**Lifecycle phases:** Phase 1 (design context), Phase 3 (pattern check), Phase 4 (context before each task)

---

### 🎨 `gem-designer`

**Model:** `claude-sonnet-4.6`

**Persona:** Creative but pragmatic. Explores 3 design directions (ToT) before committing.

**Summary:** Produce draft UI/UX design — Mermaid diagrams, component layout, data model sketch, API shape. In Phase 1, produces a draft only — Phase 3 does the full architectural review.

**Lifecycle phase:** Phase 1 (design first draft, invoked by `requirement-intake`)

---

### 📄 `gem-documentation-writer`

**Model:** `gemini-3.1-pro`

**Persona:** Structured writer. Follows templates strictly. No editorializing.

**Summary:** Create new lifecycle docs from scratch using the standard templates. Used exclusively in Phase 1 — all subsequent updates go through `lifecycle-scribe`.

**Lifecycle phase:** Phase 1 (creates `requirements.md`, `design.md`, `planning.md`)

**Output files:**
- `docs/ai/requirements/feature-{name}.md`
- `docs/ai/design/feature-{name}.md`
- `docs/ai/planning/feature-{name}.md`

---

### 📋 `gem-planner`

**Model:** `claude-sonnet-4.6`

**Persona:** DAG thinker. Everything is a dependency graph. Max 5 sub-steps per task.

**Summary:** Decompose a planning doc task into ordered atomic sub-steps, each independently executable and verifiable. Operates within Phase 4 — not a standalone phase agent.

**Lifecycle phase:** Phase 4 (task decomposition before each implementation)

---

### 🔨 `gem-implementer`

**Model:** `claude-opus-4.6`

**Persona:** Disciplined coder. TDD only. Never deviates from design without flagging it.

**Summary:** Implement a single task using TDD: write failing test → implement → make pass → refactor. Follows design doc exactly. Reports any deviation back to Orchestrator.

**Lifecycle phase:** Phase 4 (main implementer per task)

---

### 🐛 `gem-debugger`

**Model:** `claude-sonnet-4.6`

**Persona:** Detective. Traces errors to origin. Never guesses — evidence-based only.

**Summary:** Root-cause analysis when `gem-implementer` is blocked. Traces error back to origin, proposes a focused fix. Does not speculatively change unrelated code.

**Lifecycle phase:** Phase 4 (conditional — only if implementer blocked)

---

### 🔎 `gem-reviewer`

**Model:** `gpt-5.3-codex`

**Persona:** Thorough reviewer. File-by-file, no skipping. Every finding backed by line number.

**Summary:** File-by-file code review — correctness, logic gaps, edge cases, redundancy, performance hotspots, error handling. Runs in parallel with `se-security-reviewer` in Phase 6 and Phase 8.

**Lifecycle phases:** Phase 6 (implementation check), Phase 8 (final pre-push review)

---

### 🔒 `se-security-reviewer`

**Model:** `gpt-5.4`

**Persona:** Paranoid security engineer. Assumes every input is hostile.

**Summary:** Security-focused code review using OWASP Top 10. Checks: authentication, authorization, injection, data exposure, insecure defaults, missing rate limiting. Runs in parallel with `gem-reviewer`.

**Lifecycle phases:** Phase 6 (implementation check), Phase 8 (final pre-push review)

---

### ✅ `doublecheck`

**Model:** `claude-haiku-4.5`

**Persona:** Anti-hallucination filter. If a finding isn't grounded in code, it doesn't ship.

**Summary:** Verifies outputs from adversarial agents (`gem-critic`, `devils-advocate`, `gem-reviewer`, `se-security-reviewer`). Removes findings not supported by evidence. Confirms severity classifications are justified.

**Lifecycle phases:** Phase 2, Phase 6, Phase 8

---

### 🧠 `knowledge-doc-auditor`

**Model:** `claude-sonnet-4.6`

**Persona:** Structural stickler. Sections must exist. TBD fields must be resolved. Cross-refs must be valid.

**Summary:** Audit `docs/ai/` files for structural compliance — section existence, frontmatter validity, unresolved `[TBD]` fields, cross-reference consistency. Also used in Phase 6 to detect implementation drift vs design doc.

**Lifecycle phases:** Phase 1 (domain gap check), Phase 2 (structural audit), Phase 6 (drift check), Phase 8 (docs completeness)

---

### 🧪 `knowledge-quality-evaluator`

**Model:** `claude-sonnet-4.6`

**Persona:** Requirement auditor. Every claim gets a verdict — no passing by default.

**Summary:** For each requirement, evaluate whether design and planning docs provide coverage. Verdict per item: `PASS` / `PARTIAL` / `MISSING` / `MISLEADING` / `OBSOLETE`. `MISSING` and `MISLEADING` are always blocking.

**Lifecycle phases:** Phase 2 (quality evaluation), Phase 3 (coverage checker)

---

### 😈 `gem-critic`

**Model:** `claude-sonnet-4.6`

**Persona:** Constructive adversary. Finds hidden costs, scalability risks, wrong abstractions.

**Summary:** Challenge design assumptions — "Why this approach?", "What is the hidden cost?", "What breaks at scale?" Does NOT suggest rewrites — only raises questions and flags risks.

**Lifecycle phases:** Phase 2 (adversarial review), Phase 3 (architecture critic)

---

### 👿 `devils-advocate`

**Model:** `claude-sonnet-4.6`

**Persona:** Destroyer. Actively tries to break the design. Edge cases, failure modes, NFR violations.

**Summary:** Actively tries to break the design — edge cases not covered, failure modes, security surface not addressed, NFRs that will be violated. In Phase 8, stress-tests final implementation under failure scenarios (concurrent users, malformed input, missing env vars).

**Lifecycle phases:** Phase 2 (adversarial review), Phase 8 (stress-test)

---

### 🔬 `research-technical-spike`

**Model:** `claude-sonnet-4.6`

**Persona:** Empirical scientist. Validate, don't assume. Evidence over intuition.

**Summary:** Investigate risky technical decisions flagged in planning doc as spike tasks. Validates feasibility against actual codebase + dependencies. Verdict per spike: `VALIDATED` / `RISKY` / `INVALIDATED`. Conditional — only invoked if spike tasks exist.

**Lifecycle phase:** Phase 3 (conditional — only if spike tasks in planning doc)

---

### 🧹 `janitor`

**Model:** `gemini-3-flash`

**Persona:** Neat freak. Everything has a place. Unnamed magic numbers are a sin.

**Summary:** Cleanup pass on changed files — dead code, unused imports, inconsistent naming, magic numbers without constants, missing inline comments on complex logic. Reports only by default (does NOT auto-apply unless user explicitly says to).

**Lifecycle phase:** Phase 8 (cleanup pass before final verdict)

---

### 🧩 `polyglot-test-implementer`

**Model:** `gpt-5.3-codex`

**Persona:** Test-first engineer. A line of code without a test is a bug waiting to happen.

**Summary:** Write unit + integration tests targeting 100% coverage. Calls `polyglot-test-tester` and `polyglot-test-fixer` internally — full TDD loop without Orchestrator involvement.

**Lifecycle phase:** Phase 7 — Write Tests (main workhorse)

**Output files:**
- Test files co-located with components (e.g., `Component.test.tsx`)

---

### ▶️ `polyglot-test-tester`

**Model:** `gemini-3-flash`

**Persona:** Evidence collector. No test output = no claim of passing.

**Summary:** Run the full test suite and produce a coverage report. Identifies files below 100% coverage. Used as the final gate in Phase 7 before advancing to Phase 8.

**Lifecycle phase:** Phase 7 (coverage runner + gap report)

---

### 🔧 `polyglot-test-fixer`

**Model:** `gpt-5.3-codex-mini`

**Persona:** Compiler whisperer. Fixes errors without changing intent.

**Summary:** Fix compilation errors and failing tests automatically. Called internally by `polyglot-test-implementer` — not usually invoked directly.

**Lifecycle phase:** Phase 7 (called internally by `polyglot-test-implementer`)

---

### 📋 `Plan`

**Summary:** Research and outline multi-step implementation plans before any code is written. Fallback orchestrator when `Gem Orchestrator` is unavailable.

**Use when:**
- Starting a new feature that needs a structured breakdown
- Asking "how should I approach X?"
- Orchestrating dev-lifecycle phases without dedicated Gem Orchestrator

---

### 🔒 `CVE Remediator`

**Summary:** Detect and fix security vulnerabilities (CVEs) in project dependencies across any ecosystem while maintaining a working build.

**Use when:**
- Running a security audit
- A dependency has a known CVE
- Bumping vulnerable packages safely without breaking the build

**Ecosystems:** npm, pip, Maven, NuGet, Go, Rust, RubyGems, Composer, etc.

---

## 🔀 Agent ↔ Phase Mapping

> Shows which agents handle which phase in the dev-lifecycle skill.
> Source of truth: [`ai-workspace/dev-lifecycle/`](./dev-lifecycle/dev-lifecycle-summary.md)

### Per-phase agent roster

| Phase | Name | Entry Agent | Sub-agents |
|-------|------|-------------|------------|
| **0** | Orchestrator | `gem-orchestrator` | *(routes all phases — see phase routing table in agent file)* |
| **1** | Collector | `requirement-intake` | `knowledge-doc-auditor` · `bui-knowledge-builder` · `gem-researcher` · `gem-designer` · `gem-documentation-writer` |
| **2** | Reviewer | *(Orchestrator routes)* | `knowledge-doc-auditor` · `knowledge-quality-evaluator` · `gem-critic` ∥ `devils-advocate` → `doublecheck` → `review-coordinator` |
| **3** | Design Review | *(Orchestrator routes)* | `gem-researcher` → `gem-critic` → `research-technical-spike`* → `knowledge-quality-evaluator` → `review-coordinator` |
| **4** | Execute Plan | *(Orchestrator routes)* | `gem-planner` → `gem-researcher` → `gem-implementer` → `gem-debugger`* → `lifecycle-scribe` |
| **5** | Update Planning | `lifecycle-scribe` | *(internal — no sub-agents)* |
| **6** | Check Implementation | *(Orchestrator routes)* | `knowledge-doc-auditor` → `gem-reviewer` ∥ `se-security-reviewer` → `doublecheck` → `review-coordinator` |
| **6.5** | Manual Verify | *(Human gate)* | — |
| **7** | Write Tests | *(Orchestrator routes)* | `polyglot-test-implementer` → `gem-browser-tester`* → `playwright-tester`* → `polyglot-test-tester` → `lifecycle-scribe` |
| **8** | Code Review | *(Orchestrator routes)* | `gem-reviewer` ∥ `se-security-reviewer` → `doublecheck` → `janitor` → `devils-advocate` → `knowledge-doc-auditor` → `review-coordinator` |

> `*` = conditional — only invoked when specific conditions are met (spike tasks exist, frontend feature, blocked, etc.)

---

### Per-agent phase coverage

| Agent | Phases | Role in each phase |
|-------|--------|--------------------|
| `requirement-intake` | 1 | Hybrid Coordinator — owns all of Phase 1 |
| `review-coordinator` | 2, 3, 6, 8 | Synthesis Coordinator — final verdict in every review phase |
| `lifecycle-scribe` | 4, 5, 7 | Doc tracker (P4) · Progress reconciler (P5) · Testing doc updater (P7) |
| `knowledge-doc-auditor` | 1, 2, 6, 8 | Domain gap check (P1) · Structural audit (P2) · Drift check (P6) · Docs completeness (P8) |
| `knowledge-quality-evaluator` | 2, 3 | Requirements quality verdicts (P2) · Design coverage matrix (P3) |
| `gem-researcher` | 1, 3, 4 | Design context (P1) · Pattern check (P3) · Task context (P4) |
| `gem-critic` | 2, 3 | Adversarial review (P2) · Architecture critic (P3) |
| `devils-advocate` | 2, 8 | Adversarial review (P2) · Final stress-test (P8) |
| `doublecheck` | 2, 6, 8 | Anti-hallucination filter on sub-agent outputs |
| `gem-reviewer` | 6, 8 | Code review — parallel with `se-security-reviewer` |
| `se-security-reviewer` | 6, 8 | Security pass — parallel with `gem-reviewer` |
| `gem-implementer` | 4 | TDD implementer per task |
| `gem-planner` | 4 | Task decomposition |
| `gem-debugger` | 4 | Conditional — unblocks stuck tasks |
| `gem-designer` | 1 | Design first draft (delegated by `requirement-intake`) |
| `gem-documentation-writer` | 1 | Doc creation from scratch (delegated by `requirement-intake`) |
| `bui-knowledge-builder` | 1 | BUI catalog refresh before design |
| `research-technical-spike` | 3 | Conditional — validates spike tasks |
| `polyglot-test-implementer` | 7 | Unit + integration tests |
| `polyglot-test-tester` | 7 | Coverage runner + gap report |
| `polyglot-test-fixer` | 7 | Compilation + test fixer (internal to `polyglot-test-implementer`) |
| `gem-browser-tester` | 7 | E2E + accessibility — frontend only |
| `playwright-tester` | 7 | Playwright test file writer |
| `janitor` | 8 | Cleanup pass |

---

## 🔧 Skills → Agents Mapping

> Skills trong `.claude/skills/` là tập hợp rules/patterns mà **agents tham khảo** khi thực thi. Bảng này cho thấy skill nào liên quan đến agent nào và tình trạng hiện tại.
>
> **Legend:** ✅ Referred in agent file · ⚠️ Should refer but not yet · ➖ Not applicable

| Skill | Description | Relevant Agents | Status |
|-------|-------------|-----------------|--------|
| `dev-lifecycle` | 8-phase SDLC workflow, phase references, lint/check-status commands | `gem-orchestrator` | ✅ Knowledge Sources #3 |
| `agent-orchestration` | Scan→Assess→Act loop for managing running AI agent processes via CLI | `gem-orchestrator` | ✅ Knowledge Sources #5 |
| `tdd` | Red→Green→Refactor — write failing test before production code | `gem-implementer`, `polyglot-test-implementer` | ✅ Knowledge Sources #1 in both agents |
| `verify` | Evidence-based completion — require fresh command output before claiming success | `gem-orchestrator`, `lifecycle-scribe`, `polyglot-test-tester` | ✅ Knowledge Sources in all 3 agents |
| `debug` | Structured debugging workflow — reproduce → root cause → fix plan | `gem-debugger` | ✅ Knowledge Sources #1 |
| `capture-knowledge` | Document code entry points and save to domain knowledge docs | `knowledge-doc-auditor` | ✅ Knowledge Sources #2 (pre-existing) |
| `memory` | AI DevKit memory CLI (`npx ai-devkit@latest memory search/store`) | All agents using memory (P1–P3 mainly) | ⚠️ SKILL.md uses CLI commands — agents use MCP directly; patterns differ |
| `mermaid-diagrams` | Mermaid syntax guide for software diagrams | `gem-designer`, `gem-documentation-writer` | ✅ Knowledge Sources #1 (designer) · #3 (doc-writer) |
| `simplify-implementation` | Reduce complexity, improve maintainability | `janitor` | ✅ Knowledge Sources #1 |
| `refactor` | Surgical code refactoring without behavior change | `janitor` | ✅ Knowledge Sources #2 |
| `technical-writer` | Review and improve documentation for novice users | `gem-documentation-writer` | ✅ Knowledge Sources #2 |
| `document-writer` | Writing style guide, active voice, MDC syntax | `gem-documentation-writer` | ✅ Knowledge Sources #1 |
| `frontend-design` | Production-grade frontend interfaces, design quality | `gem-designer` | ✅ Knowledge Sources #2 |
| `api-patterns` | REST vs GraphQL vs tRPC selection, response formats, versioning | `gem-designer` | ✅ Knowledge Sources #3 (conditional — API tasks) |
| `agent-md-refactor` | Refactor bloated agent instruction files | *(meta — for maintaining agent files)* | ➖ Not invoked at runtime |
| `find-skills` | Help users discover installable skills | *(meta — for user discovery)* | ➖ Not invoked at runtime |


---

## ⚡ Quick Decision Guide

```
Need to...                                → Use
──────────────────────────────────────────────────────────────────────
Start a new feature (Phase 1)             → requirement-intake
Review requirements (Phase 2)             → review-coordinator + sub-agents
Review design (Phase 3)                   → review-coordinator + sub-agents
Implement a task (Phase 4)                → gem-implementer (via gem-planner + gem-researcher)
Track progress after a task (Phase 5)     → lifecycle-scribe
Check implementation (Phase 6)            → gem-reviewer + se-security-reviewer
Write tests (Phase 7)                     → polyglot-test-implementer
Final code review (Phase 8)               → gem-reviewer + review-coordinator
──────────────────────────────────────────────────────────────────────
Migrate a plugin from MUI to BUI          → bui-migrator
Refresh BUI component catalog             → bui-knowledge-builder
Test UI in browser / E2E                  → gem-browser-tester
Write/fix Playwright test files           → playwright-tester
Update docs/ai/ lifecycle docs            → lifecycle-scribe
Plan a feature before coding              → Plan
Fix a CVE in dependencies                 → CVE Remediator
```
