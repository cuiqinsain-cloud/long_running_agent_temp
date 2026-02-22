#!/bin/bash
# Claude Code 循环执行脚本（测试版本）
# 用于在容器内持续运行 Coding Agent，每次完成后自动开始下一轮

set -e

# 确保日志目录存在
mkdir -p agent_logs

echo "🤖 Starting Claude Code Agent Loop..."
echo "📝 Logs will be saved to: agent_logs/"
echo ""
echo "选择运行模式："
echo "1. 交互模式（直接运行 claude，可正常对话）"
echo "2. 自动模式（使用 --dangerously-skip-permissions，记录日志）"
echo ""
read -p "请选择 [1-2]: " mode

case $mode in
    1)
        echo ""
        echo "📋 交互模式启动"
        echo "💡 提示: 直接与 Claude 对话，无日志记录"
        echo "⚠️  输入 /exit 或按 Ctrl+D 退出当前会话"
        echo ""

        while true; do
            echo "▶️  Starting interactive session at $(date)"
            echo ""

            # 直接运行 claude，不记录日志
            claude

            EXIT_CODE=$?

            echo ""
            if [ $EXIT_CODE -eq 0 ]; then
                echo "✅ Session completed"
            else
                echo "❌ Session exited with code $EXIT_CODE"
            fi

            echo ""
            read -p "继续下一轮？[Y/n]: " continue_loop
            if [ "$continue_loop" = "n" ] || [ "$continue_loop" = "N" ]; then
                echo "👋 退出循环"
                break
            fi

            echo ""
            echo "⏳ Starting next session in 3 seconds..."
            sleep 3
            echo ""
        done
        ;;
    2)
        echo ""
        echo "📋 自动模式启动（无交互，记录日志）"
        echo "⚠️  按 Ctrl+C 可以停止循环"
        echo ""

        while true; do
            COMMIT=$(git rev-parse --short=6 HEAD 2>/dev/null || echo "no-git")
            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
            LOGFILE="agent_logs/agent_${COMMIT}_${TIMESTAMP}.log"

            echo "▶️  Starting automated session at $(date)"
            echo "📄 Log file: $LOGFILE"

            # 自动模式：使用 --dangerously-skip-permissions
            # 从 CLAUDE.md 读取提示词（Coding Agent 的配置）
            if [ -f "CLAUDE.md" ]; then
                echo "say hi" | claude --dangerously-skip-permissions \
                       -p "$(cat CLAUDE.md)" \
                       &> "$LOGFILE"
            else
                echo "say hi" | claude --dangerously-skip-permissions &> "$LOGFILE"
            fi

            EXIT_CODE=$?

            if [ $EXIT_CODE -eq 0 ]; then
                echo "✅ Session completed successfully"
            else
                echo "❌ Session exited with code $EXIT_CODE"
                echo "📄 Check log: $LOGFILE"
            fi

            echo ""
            echo "⏳ Waiting 5 seconds before next session..."
            sleep 5
        done
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "✓ Loop completed."
