#!/bin/bash
# dev-lifecycle-agents — Project Setup Script
# Run once in any new project to install the skill files at the paths
# expected by gem-orchestrator.
#
# Usage:
#   bash setup-project.sh
#   bash setup-project.sh --plugin-dir /custom/path/to/dev-lifecycle-agents

set -e

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"

# Allow override via --plugin-dir flag
if [[ "$1" == "--plugin-dir" && -n "$2" ]]; then
  PLUGIN_DIR="$2"
fi

echo "🔧 dev-lifecycle-agents setup"
echo "   Plugin dir : $PLUGIN_DIR"
echo "   Project dir: $PROJECT_DIR"
echo ""

# 1. Copy skills to .claude/skills/ (orchestrator reads from here)
echo "📁 Copying skills → .claude/skills/ ..."
mkdir -p "$PROJECT_DIR/.claude/skills"
cp -r "$PLUGIN_DIR/skills/"* "$PROJECT_DIR/.claude/skills/"
echo "   ✅ Skills copied"

# 2. Create ai-workspace structure (orchestrator writes state here)
echo "📁 Creating ai-workspace structure ..."
mkdir -p "$PROJECT_DIR/ai-workspace/temp"
mkdir -p "$PROJECT_DIR/ai-workspace/dev-lifecycle"

# Copy summary + phase specs (read-only references)
cp "$PLUGIN_DIR/ai-workspace/dev-lifecycle/"*.md "$PROJECT_DIR/ai-workspace/dev-lifecycle/" 2>/dev/null || true
cp "$PLUGIN_DIR/ai-workspace/agents-catalog.md"  "$PROJECT_DIR/ai-workspace/" 2>/dev/null || true
echo "   ✅ ai-workspace created"

# 3. Create docs/ai/ structure for feature docs
echo "📁 Creating docs/ai/ structure ..."
for dir in requirements design planning implementation testing; do
  mkdir -p "$PROJECT_DIR/docs/ai/$dir"
done
echo "   ✅ docs/ai/ created"

echo ""
echo "✅ Setup complete! You can now run:"
echo "   /fleet start feature <feature-name>"

