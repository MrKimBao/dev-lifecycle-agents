# dev-lifecycle-agents

A GitHub Copilot CLI plugin bundling a full 8-phase dev lifecycle pipeline.

## What's included

- **26 agents** — orchestrator, implementer, reviewer, planner, debugger, tester, and more
- **Skills** — dev-lifecycle, verify, tdd, debug, agent-orchestration, and more
- **Phase reference docs** — detailed specs for all 8 phases

## Install & Setup

### Step 1 — Install plugin (once per machine)
```bash
copilot plugin marketplace add YOUR-USERNAME/dev-lifecycle-agents
copilot plugin install dev-lifecycle-agents@YOUR-USERNAME
```

### Step 2 — Setup new project (once per project)
The plugin agents are globally available, but skill reference files need to exist
in the project directory (orchestrator reads them via relative paths).

Run the setup script from the plugin directory:
```bash
# Find where the plugin was installed
ls ~/.copilot/installed-plugins/YOUR-USERNAME/dev-lifecycle-agents/

# Run setup in your new project
cd /path/to/your-new-project
bash ~/.copilot/installed-plugins/YOUR-USERNAME/dev-lifecycle-agents/setup-project.sh
```

Or if using local plugin dir:
```bash
cd /path/to/your-new-project
bash /path/to/dev-lifecycle-agents/setup-project.sh
```

### What setup-project.sh does
- Copies `skills/` → `.claude/skills/` (orchestrator reads phase references from here)
- Creates `ai-workspace/` structure (orchestrator writes state files here)
- Creates `docs/ai/` folders (phase 1 writes feature docs here)


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

