#!/bin/bash
# Docker 容器日志监控脚本
# 实时查看容器日志和 agent 运行日志

echo "📊 Docker 容器日志监控"
echo "======================================"
echo ""

# 检查容器是否运行
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ 错误: 容器未运行"
    echo "请先运行: ./init-env.sh"
    exit 1
fi

echo "选择监控模式："
echo "1. 容器日志（docker-compose logs）"
echo "2. Agent 运行日志（agent_logs/）"
echo "3. 同时监控容器和最新 agent 日志"
echo ""
read -p "请选择 [1-3]: " choice

case $choice in
    1)
        echo ""
        echo "📋 实时查看容器日志（按 Ctrl+C 退出）..."
        echo ""
        docker-compose logs -f
        ;;
    2)
        echo ""
        echo "📋 查看 agent 日志..."
        echo ""
        if [ -d "agent_logs" ] && [ "$(ls -A agent_logs 2>/dev/null)" ]; then
            echo "可用的日志文件："
            ls -lht agent_logs/ | head -10
            echo ""
            LATEST_LOG=$(ls -t agent_logs/*.log 2>/dev/null | head -1)
            if [ -n "$LATEST_LOG" ]; then
                echo "📄 最新日志: $LATEST_LOG"
                echo ""
                read -p "查看最新日志？[Y/n]: " view_latest
                if [ "$view_latest" != "n" ] && [ "$view_latest" != "N" ]; then
                    echo ""
                    echo "======================================"
                    tail -f "$LATEST_LOG"
                fi
            else
                echo "⚠️  暂无日志文件"
            fi
        else
            echo "⚠️  agent_logs/ 目录为空"
            echo "提示: 运行 ./run-agent-loop.sh 后会生成日志"
        fi
        ;;
    3)
        echo ""
        echo "📋 同时监控容器日志和 agent 日志（按 Ctrl+C 退出）..."
        echo ""

        # 在后台监控容器日志
        docker-compose logs -f &
        DOCKER_PID=$!

        # 监控最新的 agent 日志
        if [ -d "agent_logs" ]; then
            LATEST_LOG=$(ls -t agent_logs/*.log 2>/dev/null | head -1)
            if [ -n "$LATEST_LOG" ]; then
                echo "📄 监控最新日志: $LATEST_LOG"
                tail -f "$LATEST_LOG" &
                TAIL_PID=$!
            fi
        fi

        # 等待用户中断
        trap "kill $DOCKER_PID $TAIL_PID 2>/dev/null; exit" INT TERM
        wait
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac
