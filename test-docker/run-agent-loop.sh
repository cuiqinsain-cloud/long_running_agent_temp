#!/bin/bash
# Claude Code 循环执行脚本（测试版本）
# 用于在容器内持续运行 Coding Agent，每次完成后自动开始下一轮

set -e

# 确保日志目录存在
mkdir -p agent_logs

echo "🤖 Starting Claude Code Agent Loop (Test Mode)..."
echo "📝 Logs will be saved to: agent_logs/"
echo "⚠️  Press Ctrl+C to stop"
echo ""

# 测试模式：只运行一次
COMMIT=$(git rev-parse --short=6 HEAD 2>/dev/null || echo "no-git")
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="agent_logs/agent_${COMMIT}_${TIMESTAMP}.log"

echo "▶️  Starting test session at $(date)"
echo "📄 Log file: $LOGFILE"

# 测试运行 Claude Code（使用简单的测试提示）
echo "Testing Claude Code with --dangerously-skip-permissions flag..."
echo "say hi" | claude --dangerously-skip-permissions &> "$LOGFILE"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Test session completed successfully"
else
    echo "❌ Test session exited with code $EXIT_CODE"
    echo "📄 Check log: $LOGFILE"
fi

echo ""
echo "✓ Test completed. Check the log file for output."
