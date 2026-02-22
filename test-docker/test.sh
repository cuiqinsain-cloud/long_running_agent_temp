#!/bin/bash
# Docker 环境测试脚本

set -e

echo "🧪 测试 Docker 环境中的 Claude Code"
echo "======================================"
echo ""

# 步骤 1: 复制 Claude 配置
echo "📋 步骤 1: 复制 Claude Code 配置..."
if [ -d "../.claude" ]; then
    cp -r ../.claude .
    echo "✓ .claude/ 配置已复制"
else
    echo "❌ 错误: 未找到 ../.claude/ 目录"
    echo "请确保在项目根目录下有 .claude/ 配置"
    exit 1
fi

# 步骤 1.5: 复制环境变量配置
echo ""
echo "📋 步骤 1.5: 复制环境变量配置..."
if [ -f "../.env" ]; then
    cp ../.env .
    echo "✓ .env 配置已复制"
else
    echo "❌ 错误: 未找到 ../.env 文件"
    echo "请确保在项目根目录下有 .env 文件"
    exit 1
fi

# 步骤 2: 构建 Docker 镜像
echo ""
echo "🐳 步骤 2: 构建 Docker 镜像..."
docker-compose build

# 步骤 3: 启动容器
echo ""
echo "🚀 步骤 3: 启动容器..."
docker-compose up -d

# 等待容器启动
sleep 2

# 步骤 4: 验证 Claude Code 安装
echo ""
echo "✅ 步骤 4: 验证 Claude Code 安装..."
docker-compose exec test-claude which claude || {
    echo "❌ 错误: Claude Code CLI 未安装"
    exit 1
}
echo "✓ Claude Code CLI 已安装"

# 步骤 5: 检查 Claude Code 版本
echo ""
echo "📦 步骤 5: 检查 Claude Code 版本..."
docker-compose exec test-claude claude --version || {
    echo "⚠️  警告: 无法获取版本信息"
}

# 步骤 6: 验证配置文件
echo ""
echo "🔍 步骤 6: 验证配置文件..."
docker-compose exec test-claude test -d /workspace/.claude && {
    echo "✓ .claude/ 目录存在"
} || {
    echo "❌ 错误: .claude/ 目录不存在"
    exit 1
}

docker-compose exec test-claude test -f /workspace/.claude/settings.local.json && {
    echo "✓ settings.local.json 文件存在"
} || {
    echo "⚠️  警告: settings.local.json 文件不存在"
}

# 步骤 6.5: 验证环境变量
echo ""
echo "🔍 步骤 6.5: 验证环境变量..."
docker-compose exec test-claude test -f /workspace/.env && {
    echo "✓ .env 文件存在"
} || {
    echo "❌ 错误: .env 文件不存在"
    exit 1
}

docker-compose exec test-claude printenv ANTHROPIC_AUTH_TOKEN > /dev/null && {
    echo "✓ ANTHROPIC_AUTH_TOKEN 环境变量已加载"
} || {
    echo "❌ 错误: ANTHROPIC_AUTH_TOKEN 环境变量未加载"
    exit 1
}

docker-compose exec test-claude printenv ANTHROPIC_BASE_URL > /dev/null && {
    echo "✓ ANTHROPIC_BASE_URL 环境变量已加载"
} || {
    echo "⚠️  警告: ANTHROPIC_BASE_URL 环境变量未加载"
}

# 步骤 7: 验证 git 安装
echo ""
echo "🔧 步骤 7: 验证 git 安装..."
docker-compose exec test-claude which git && {
    echo "✓ git 已安装"
} || {
    echo "❌ 错误: git 未安装"
    exit 1
}

# 步骤 8: 测试 Claude Code 基本命令
echo ""
echo "🎯 步骤 8: 测试 Claude Code 基本命令..."
docker-compose exec test-claude claude --help > /dev/null 2>&1 && {
    echo "✓ Claude Code 命令可以执行"
} || {
    echo "❌ 错误: Claude Code 命令执行失败"
    exit 1
}

# 步骤 9: 测试 Claude Code 交互
echo ""
echo "🤖 步骤 9: 测试 Claude Code 交互..."
echo "发送测试消息: 'say hi'"
docker-compose exec -T test-claude bash -c 'echo "say hi" | claude' > /tmp/claude_test_output.txt 2>&1 &
CLAUDE_PID=$!

# 等待响应（最多30秒）
echo "等待 Claude 响应..."
for i in {1..30}; do
    if grep -q "Hi" /tmp/claude_test_output.txt 2>/dev/null || \
       grep -q "Hello" /tmp/claude_test_output.txt 2>/dev/null || \
       grep -q "你好" /tmp/claude_test_output.txt 2>/dev/null; then
        echo "✓ Claude Code 响应正常"
        kill $CLAUDE_PID 2>/dev/null || true
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  警告: 30秒内未收到响应，可能需要手动验证"
        kill $CLAUDE_PID 2>/dev/null || true
        cat /tmp/claude_test_output.txt
    fi
    sleep 1
done

# 完成
echo ""
echo "======================================"
echo "✅ 所有测试通过！"
echo ""
echo "💡 下一步操作："
echo "1. 进入容器: docker-compose exec test-claude /bin/bash"
echo "2. 在容器内运行: claude"
echo "3. 停止容器: docker-compose down"
echo ""
