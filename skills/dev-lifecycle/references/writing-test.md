# Phase 7: Write Tests

> ⚠️ **Prerequisite — Phase 6.5 Manual Verify gate**: Before starting this phase, confirm with the user that manual verification on the running app has passed. If not yet done, stop and ask: *"Anh đã verify manually trên app chưa? Phase 7 chỉ bắt đầu sau khi manual verify pass."* Do NOT proceed until confirmed.

Add tests targeting 100% coverage. Reference `docs/ai/testing/feature-{name}.md` and success criteria from requirements/design docs.

1. **Confirm manual verify** — ask the user to confirm Phase 6.5 passed before proceeding.
2. **Gather context** — feature name, changes summary, environment (backend/frontend/full-stack), existing test suites, flaky tests to avoid.
3. **Analyze** the testing template, success criteria, edge cases, available mocks/fixtures.
4. **Unit tests** — cover happy path, edge cases, error handling for each module. Highlight missing branches.
5. **Integration tests** — critical cross-component flows, setup/teardown, boundary/failure cases.
6. **Coverage** — run coverage tooling, identify gaps, suggest additional tests if < 100%.
7. **Update** `docs/ai/testing/feature-{name}.md` with test file links and results.

**Next**: Phase 8 (Code Review). If tests reveal design flaws → back to Phase 3.
