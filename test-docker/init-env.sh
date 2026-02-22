#!/bin/bash
# Docker 环境初始化脚本
# 用于创建测试环境并启动容器

set -e

echo "🚀 初始化 Docker 测试环境"
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

# 步骤 2: 复制环境变量配置
echo ""
echo "📋 步骤 2: 复制环境变量配置..."
if [ -f "../.env" ]; then
    cp ../.env .
    echo "✓ .env 配置已复制"
else
    echo "❌ 错误: 未找到 ../.env 文件"
    echo "请确保在项目根目录下有 .env 文件"
    exit 1
fi

# 步骤 3: 创建日志目录
echo ""
echo "📁 步骤 3: 创建日志目录..."
mkdir -p agent_logs
echo "✓ agent_logs/ 目录已创建"

# 步骤 4: 构建 Docker 镜像
echo ""
echo "🐳 步骤 4: 构建 Docker 镜像..."
docker-compose build

# 步骤 5: 启动容器
echo ""
echo "🚀 步骤 5: 启动容器..."
docker-compose up -d

# 等待容器启动
echo ""
echo "⏳ 等待容器启动..."
sleep 3

# 步骤 6: 验证容器状态
echo ""
echo "✅ 步骤 6: 验证容器状态..."
if docker-compose ps | grep -q "Up"; then
    echo "✓ 容器运行正常"
else
    echo "❌ 错误: 容器未正常启动"
    exit 1
fi

# 步骤 7: 验证基本配置
echo ""
echo "🔍 步骤 7: 验证基本配置..."

# 验证 Claude Code 安装
docker-compose exec test-claude which claude > /dev/null && {
    echo "✓ Claude Code CLI 已安装"
} || {
    echo "❌ 错误: Claude Code CLI 未安装"
    exit 1
}

# 验证用户
CURRENT_USER=$(docker-compose exec test-claude whoami | tr -d '\r')
if [ "$CURRENT_USER" = "coder" ]; then
    echo "✓ 容器使用非 root 用户: $CURRENT_USER"
else
    echo "❌ 错误: 容器使用的用户是 $CURRENT_USER，应该是 coder"
    exit 1
fi

# 验证环境变量
docker-compose exec test-claude printenv ANTHROPIC_AUTH_TOKEN > /dev/null && {
    echo "✓ ANTHROPIC_AUTH_TOKEN 环境变量已加载"
} || {
    echo "❌ 错误: ANTHROPIC_AUTH_TOKEN 环境变量未加载"
    exit 1
}

# 验证循环脚本
docker-compose exec test-claude test -x /workspace/run-agent-loop.sh && {
    echo "✓ run-agent-loop.sh 脚本可执行"
} || {
    echo "❌ 错误: run-agent-loop.sh 脚本不可执行"
    exit 1
}

# 完成
echo ""
echo "======================================"
echo "✅ 初始化完成！容器已启动"
echo ""
echo "📊 容器信息："
docker-compose ps
echo ""
echo "💡 下一步操作："
echo ""
echo "1. 查看容器日志："
echo "   ./monitor-logs.sh"
echo ""
echo "2. 进入容器交互："
echo "   docker-compose exec test-claude /bin/bash"
echo ""
echo "3. 在容器内运行 Claude Code："
echo "   docker-compose exec test-claude claude"
echo ""
echo "4. 在容器内运行循环脚本："
echo "   docker-compose exec test-claude ./run-agent-loop.sh"
echo ""
echo "5. 清理环境："
echo "   ./cleanup.sh"
echo ""
