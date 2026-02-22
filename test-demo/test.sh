#!/bin/bash
# Coding Agent 自动化测试
# 预设项目结构，测试 Coding Agent 在 Docker 容器内自动完成所有开发任务

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 测试配置
WORKSPACE="coding-workspace"
TEST_ROOT=$(pwd)
PROJECT_ROOT=$(cd .. && pwd)

echo -e "${BLUE}🧪 Coding Agent 自动化测试${NC}"
echo "======================================"
echo ""

# 清理函数
cleanup() {
    echo ""
    echo -e "${YELLOW}🧹 清理测试环境...${NC}"
    cd "$TEST_ROOT"
    if [ -d "$WORKSPACE" ]; then
        cd "$WORKSPACE"
        docker-compose down 2>/dev/null || true
        cd "$TEST_ROOT"
        rm -rf "$WORKSPACE"
        echo -e "${GREEN}✓ 已清理${NC}"
    fi
}

# 询问是否自动清理
echo -e "${YELLOW}测试完成后是否自动清理？ (y/n)${NC}"
read -r auto_cleanup
if [[ "$auto_cleanup" =~ ^[Yy]$ ]]; then
    trap cleanup EXIT
fi

echo ""

# 步骤 1: 环境检查
echo -e "${BLUE}📋 步骤 1: 环境检查${NC}"
echo "--------------------------------------"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker 已安装${NC}"

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ docker-compose 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓ docker-compose 已安装${NC}"

if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo -e "${RED}❌ 未找到 .env 文件${NC}"
    exit 1
fi
echo -e "${GREEN}✓ .env 文件存在${NC}"

if ! grep -q "ANTHROPIC_AUTH_TOKEN" "$PROJECT_ROOT/.env"; then
    echo -e "${RED}❌ ANTHROPIC_AUTH_TOKEN 未配置${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ANTHROPIC_AUTH_TOKEN 已配置${NC}"

echo ""

# 步骤 2: 创建预设项目结构
echo -e "${BLUE}📁 步骤 2: 创建预设项目结构${NC}"
echo "--------------------------------------"

mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

# 复制配置
cp -r "$PROJECT_ROOT/.claude" .
cp "$PROJECT_ROOT/.env" .
echo -e "${GREEN}✓ 配置已复制${NC}"

# 创建目录
mkdir -p todo_cli tests
echo -e "${GREEN}✓ 目录已创建${NC}"

# 创建 feature_list.json
cat > feature_list.json << 'EOF'
{
  "project_name": "todo-cli",
  "features": [
    {
      "id": "F001",
      "name": "添加 TODO 项",
      "description": "实现 todo add <内容> 命令，将 TODO 项保存到 todos.json 文件",
      "complexity": "simple",
      "priority": "high",
      "passes": false
    },
    {
      "id": "F002",
      "name": "列出所有 TODO 项",
      "description": "实现 todo list 命令，显示所有 TODO 项（ID、内容、完成状态）",
      "complexity": "simple",
      "priority": "high",
      "passes": false
    },
    {
      "id": "F003",
      "name": "标记 TODO 为完成",
      "description": "实现 todo complete <id> 命令，标记指定 TODO 为已完成",
      "complexity": "simple",
      "priority": "medium",
      "passes": false
    }
  ]
}
EOF
echo -e "${GREEN}✓ feature_list.json 已创建${NC}"

# 创建 claude-progress.txt
cat > claude-progress.txt << 'EOF'
# TODO CLI 开发进度

## 项目信息
- 项目：todo-cli
- 语言：Python + Click
- 环境：Docker 容器

## 功能列表
- F001: 添加 TODO 项
- F002: 列出所有 TODO 项
- F003: 标记 TODO 为完成

## 进度
（Coding Agent 将在此记录）
EOF
echo -e "${GREEN}✓ claude-progress.txt 已创建${NC}"

# 创建 CLAUDE.md
cat > CLAUDE.md << 'EOF'
# Coding Agent

你是 Coding Agent，负责实现 feature_list.json 中的功能。

## 工作流程

1. 读取 feature_list.json 和 claude-progress.txt
2. 选择一个 passes: false 的功能
3. 实现代码和测试
4. 运行测试确保通过
5. Git commit: "feat: 实现 <功能名> (F00X)"
6. 更新 feature_list.json 设置 passes: true
7. 更新 claude-progress.txt 记录进度
8. 继续下一个功能

## 注意
- 每次只实现一个功能
- 确保测试通过再提交
- 保持代码简洁
EOF
echo -e "${GREEN}✓ CLAUDE.md 已创建${NC}"

# 创建 Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.11-alpine

RUN apk add --no-cache git bash curl nodejs npm sudo
RUN npm install -g @anthropic-ai/claude-code

# 创建非 root 用户
RUN adduser -D -u 1000 developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer

WORKDIR /workspace

# 切换到非 root 用户
USER developer

CMD ["/bin/bash"]
EOF
echo -e "${GREEN}✓ Dockerfile 已创建${NC}"

# 创建 docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  coding-agent:
    build: .
    container_name: coding-agent
    volumes:
      - .:/workspace
    working_dir: /workspace
    env_file:
      - .env
    stdin_open: true
    tty: true
    command: tail -f /dev/null
EOF
echo -e "${GREEN}✓ docker-compose.yml 已创建${NC}"

# 创建 requirements.txt
cat > requirements.txt << 'EOF'
click==8.1.7
pytest==7.4.3
EOF
echo -e "${GREEN}✓ requirements.txt 已创建${NC}"

# 创建 setup.py
cat > setup.py << 'EOF'
from setuptools import setup, find_packages

setup(
    name='todo-cli',
    version='0.1.0',
    packages=find_packages(),
    install_requires=['click==8.1.7'],
    entry_points={
        'console_scripts': [
            'todo=todo_cli.cli:cli',
        ],
    },
)
EOF
echo -e "${GREEN}✓ setup.py 已创建${NC}"

# 创建基础 Python 文件
cat > todo_cli/__init__.py << 'EOF'
"""TODO CLI"""
__version__ = '0.1.0'
EOF

cat > todo_cli/cli.py << 'EOF'
"""CLI 入口"""
import click

@click.group()
def cli():
    """TODO CLI 工具"""
    pass

if __name__ == '__main__':
    cli()
EOF

cat > tests/__init__.py << 'EOF'
EOF

echo -e "${GREEN}✓ Python 文件已创建${NC}"

# Git 初始化
git init > /dev/null 2>&1
git add . > /dev/null 2>&1
git commit -m "chore: 初始化项目" > /dev/null 2>&1
echo -e "${GREEN}✓ Git 仓库已初始化${NC}"

echo ""

# 步骤 3: 构建 Docker 镜像
echo -e "${BLUE}🐳 步骤 3: 构建 Docker 镜像${NC}"
echo "--------------------------------------"

docker-compose build
echo -e "${GREEN}✓ 镜像构建完成${NC}"

docker-compose up -d
sleep 3
echo -e "${GREEN}✓ 容器已启动${NC}"

echo ""

# 步骤 4: 验证容器环境
echo -e "${BLUE}🔍 步骤 4: 验证容器环境${NC}"
echo "--------------------------------------"

docker-compose exec -T coding-agent which claude > /dev/null 2>&1
echo -e "${GREEN}✓ Claude CLI 已安装${NC}"

docker-compose exec -T coding-agent which git > /dev/null 2>&1
echo -e "${GREEN}✓ Git 已安装${NC}"

docker-compose exec -T coding-agent which python3 > /dev/null 2>&1
echo -e "${GREEN}✓ Python 已安装${NC}"

docker-compose exec -T coding-agent printenv ANTHROPIC_AUTH_TOKEN > /dev/null 2>&1
echo -e "${GREEN}✓ 环境变量已加载${NC}"

echo ""

# 步骤 5: 复制循环脚本
echo -e "${BLUE}📋 步骤 5: 准备循环执行脚本${NC}"
echo "--------------------------------------"

cp "$TEST_ROOT/agent-loop.sh" .
chmod +x agent-loop.sh
echo -e "${GREEN}✓ agent-loop.sh 已复制${NC}"

echo ""

# 步骤 6: 自动循环执行 Coding Agent
echo -e "${BLUE}🤖 步骤 6: 在容器内自动循环执行 Coding Agent${NC}"
echo "--------------------------------------"
echo -e "${YELLOW}Coding Agent 将自动完成所有功能...${NC}"
echo ""

docker-compose exec -T coding-agent bash /workspace/agent-loop.sh

echo ""
echo -e "${GREEN}✓ 自动循环执行完成${NC}"

echo ""

# 步骤 7: 验证结果
echo -e "${BLUE}✅ 步骤 7: 验证结果${NC}"
echo "--------------------------------------"

COMPLETED=$(python3 << 'PYEOF'
import json
with open('feature_list.json', 'r') as f:
    data = json.load(f)
    completed = sum(1 for f in data.get('features', []) if f.get('passes', False))
    total = len(data.get('features', []))
    print(f"{completed}/{total}")
PYEOF
)

echo "功能完成情况: $COMPLETED"

python3 << 'PYEOF'
import json
with open('feature_list.json', 'r') as f:
    data = json.load(f)
    for feature in data.get('features', []):
        status = "✓" if feature.get('passes', False) else "○"
        print(f"  {status} {feature['id']}: {feature['name']}")
PYEOF

echo ""
echo -e "${BLUE}Git 提交历史：${NC}"
git log --oneline -10

if [ -d "agent_logs" ]; then
    LOG_COUNT=$(ls -1 agent_logs/ | wc -l | tr -d ' ')
    echo ""
    echo -e "${BLUE}日志文件数: $LOG_COUNT${NC}"
fi

echo ""

# 测试总结
echo "======================================"
echo -e "${GREEN}✅ 测试完成！${NC}"
echo "======================================"
echo ""
echo -e "${BLUE}工作区: $TEST_ROOT/$WORKSPACE${NC}"
echo ""
echo -e "${BLUE}后续操作：${NC}"
echo "  查看代码: cd $TEST_ROOT/$WORKSPACE"
echo "  查看日志: cat agent_logs/*.log"
echo "  进入容器: docker-compose exec coding-agent /bin/bash"
echo "  停止容器: docker-compose down"
echo ""

if [[ ! "$auto_cleanup" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}💡 手动清理: cd $TEST_ROOT/$WORKSPACE && docker-compose down && cd .. && rm -rf $WORKSPACE${NC}"
    echo ""
fi
