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
echo "1. 交互模式（可以与 Claude 对话，同时记录日志）"
echo "2. 自动模式（使用 --dangerously-skip-permissions，无交互）"
echo ""
read -p "请选择 [1-2]: " mode

case $mode in
    1)
        echo ""
        echo "📋 交互模式启动"
        echo "💡 提示: 你可以正常与 Claude 对话，所有输入输出都会记录到日志"
        echo "⚠️  按 Ctrl+C 可以停止当前会话"
        echo ""

        while true; do
            COMMIT=$(git rev-parse --short=6 HEAD 2>/dev/null || echo "no-git")
            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
            LOGFILE="agent_logs/agent_${COMMIT}_${TIMESTAMP}.log"

            echo "▶️  Starting interactive session at $(date)"
            echo "📄 Log file: $LOGFILE"
            echo ""

            # 使用 script 命令记录交互式会话
            # -q: 安静模式，不显示启动/结束消息
            # -c: 执行命令
            # -f: 立即刷新输出
            if command -v script > /dev/null 2>&1; then
                # Linux/macOS 的 script 命令语法不同
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    # macOS
                    script -q "$LOGFILE" claude
                else
                    # Linux (Alpine)
                    script -qfc "claude" "$LOGFILE"
                fi
            else
                # 如果没有 script 命令，使用 tee
                claude 2>&1 | tee "$LOGFILE"
            fi

            EXIT_CODE=$?

            echo ""
            if [ $EXIT_CODE -eq 0 ]; then
                echo "✅ Session completed successfully"
            else
                echo "❌ Session exited with code $EXIT_CODE"
            fi

            echo "📄 Log saved to: $LOGFILE"
            echo ""

            read -p "继续下一轮？[Y/n]: " continue_loop
            if [ "$continue_loop" = "n" ] || [ "$continue_loop" = "N" ]; then
                echo "👋 退出循环"
                break
            fi

            echo ""
            echo "⏳ Starting next session in 3 seconds..."
            sleep 3
        done
        ;;
    2)
        echo ""
        echo "📋 自动模式启动（无交互）"
        echo "⚠️  按 Ctrl+C 可以停止循环"
        echo ""

        while true; do
            COMMIT=$(git rev-parse --short=6 HEAD 2>/dev/null || echo "no-git")
            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
            LOGFILE="agent_logs/agent_${COMMIT}_${TIMESTAMP}.log"

            echo "▶️  Starting automated session at $(date)"
            echo "📄 Log file: $LOGFILE"

            # 自动模式：使用 --dangerously-skip-permissions
            # 从 CLAUDE.md 读取提示词（如果存在）
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
