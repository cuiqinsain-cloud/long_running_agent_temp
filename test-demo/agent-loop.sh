#!/bin/bash
# 在 Docker 容器内循环运行 Coding Agent
# 自动完成所有功能开发任务

set -e

echo "🤖 启动 Coding Agent 循环执行模式"
echo "======================================"
echo ""

# 创建日志目录
mkdir -p agent_logs

# 循环执行
ITERATION=0
MAX_ITERATIONS=10  # 最多执行10次，防止无限循环

while [ $ITERATION -lt $MAX_ITERATIONS ]; do
    ITERATION=$((ITERATION + 1))
    COMMIT=$(git rev-parse --short=6 HEAD)
    LOGFILE="agent_logs/agent_${COMMIT}_iter${ITERATION}.log"

    echo ""
    echo "----------------------------------------"
    echo "🔄 迭代 $ITERATION - Commit: $COMMIT"
    echo "----------------------------------------"

    # 检查是否还有未完成的功能
    PENDING=$(python3 << 'PYEOF'
import json
try:
    with open('feature_list.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        pending = sum(1 for f in data.get('features', []) if not f.get('passes', False))
        print(pending)
except:
    print(0)
PYEOF
)

    if [ "$PENDING" -eq 0 ]; then
        echo "✅ 所有功能已完成！"
        break
    fi

    echo "📋 剩余功能: $PENDING"
    echo "🚀 启动 Coding Agent..."

    # 运行 Claude Code
    # 使用 --permission-mode bypassPermissions 自动绕过权限检查
    # 提供简单的提示词让 Claude 开始工作
    echo "请按照 CLAUDE.md 的指示，选择一个未完成的功能并实现它。" | \
        timeout 600 claude --permission-mode bypassPermissions &> "$LOGFILE" || {
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 124 ]; then
            echo "⚠️  超时（10分钟），继续下一次迭代"
        else
            echo "⚠️  执行出错（退出码: $EXIT_CODE），继续下一次迭代"
        fi
    }

    # 显示最后几行日志
    echo ""
    echo "📄 日志摘要（最后10行）:"
    tail -n 10 "$LOGFILE" || true

    # 检查是否有新的提交
    NEW_COMMIT=$(git rev-parse --short=6 HEAD)
    if [ "$COMMIT" != "$NEW_COMMIT" ]; then
        echo "✓ 检测到新提交: $NEW_COMMIT"
    else
        echo "⚠️  没有新提交，可能遇到问题"
    fi

    # 短暂延迟
    sleep 2
done

if [ $ITERATION -eq $MAX_ITERATIONS ]; then
    echo ""
    echo "⚠️  达到最大迭代次数 ($MAX_ITERATIONS)，停止执行"
fi

echo ""
echo "======================================"
echo "🏁 Coding Agent 循环执行完成"
echo "======================================"
echo ""

# 显示最终统计
echo "📊 最终统计:"
python3 << 'PYEOF'
import json
try:
    with open('feature_list.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        features = data.get('features', [])
        total = len(features)
        completed = sum(1 for f in features if f.get('passes', False))
        print(f"  总功能数: {total}")
        print(f"  已完成: {completed}")
        print(f"  未完成: {total - completed}")
        print("")
        print("功能状态:")
        for feature in features:
            status = "✓" if feature.get('passes', False) else "○"
            print(f"  {status} {feature['id']}: {feature['name']}")
except Exception as e:
    print(f"  错误: {e}")
PYEOF

echo ""
echo "📁 日志文件保存在: agent_logs/"
echo ""
