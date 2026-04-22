# dev-lifecycle-agents

A GitHub Copilot CLI plugin bundling a full 8-phase dev lifecycle pipeline.

## What's included

- **26 agents** — orchestrator, implementer, reviewer, planner, debugger, tester, and more
- **Skills** — dev-lifecycle, verify, tdd, debug, agent-orchestration, and more
- **Phase reference docs** — detailed specs for all 8 phases

## Install

```bash
copilot plugin install dev-lifecycle-agents@YOUR-GITHUB-USERNAME
```

Or from local directory (for development):
```bash
copilot --plugin-dir /path/to/dev-lifecycle-agents
```

## Usage

```
/fleet start feature my-feature-name
/fleet start feature fix-login-bug skip-to 4 fast autopilot
/fleet continue feature my-feature-name
```

## Flow

```
P1 (Collector) → P2 (Review Requirements) → P3 (Design Review)
→ P4 (Execute Plan) → P5 (Update Planning) → P6 (Check Implementation)
→ P6.5 (Manual Verify ⛔ never skippable) → P7 (Write Tests) → P8 (Code Review)
```

## Magic Keywords

| Keyword | Effect |
|---------|--------|
| `autopilot` | Skip all user gates |
| `fast` | Drop adversarial agents, parallel cap → 4 |
| `skip-to N` | Jump to phase N |
| `deep` | Extra review pass, lower confidence threshold |
| `complex` | Pre-mortem + multi-plan + contract-first |
| `no-tests` | Skip Phase 7 |
| `strict` | Pause after every agent |

