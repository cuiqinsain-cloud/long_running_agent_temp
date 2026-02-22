# Docker 环境测试

此目录用于测试 Claude Code 在 Docker 容器中的运行情况。

## 测试内容

1. ✅ Docker 镜像构建
2. ✅ Claude Code CLI 安装
3. ✅ 配置文件挂载
4. ✅ git 工具安装
5. ✅ 非 root 用户配置
6. ✅ sudo 权限配置
7. ✅ 循环执行脚本
8. ✅ Claude Code 基本命令执行
9. ✅ Claude Code 交互响应
10. ✅ --dangerously-skip-permissions 参数测试

## 运行测试

```bash
cd test-docker
chmod +x test.sh
./test.sh
```

## 测试步骤

脚本会自动执行以下步骤：

1. 复制 `.claude/` 配置到测试目录
2. 复制 `.env` 环境变量配置
3. 构建 Docker 镜像
4. 启动容器
5. 验证 Claude Code CLI 安装
6. 检查版本信息
7. 验证配置文件存在
8. 验证环境变量加载
9. 验证 git 安装
10. 验证非 root 用户（coder）
11. 验证 sudo 权限
12. 验证循环执行脚本存在且可执行
13. 测试 Claude Code 基本命令
14. 测试 Claude Code 交互（发送 "say hi"）
15. 测试 --dangerously-skip-permissions 参数

## 手动测试

如果需要手动测试：

```bash
# 启动容器
docker-compose up -d

# 进入容器
docker-compose exec test-claude /bin/bash

# 在容器内测试
claude --version
whoami  # 应该显示 coder
claude

# 测试循环执行脚本
./run-agent-loop.sh

# 停止容器
docker-compose down
```

## 新增功能

### 非 root 用户支持

- 容器使用 `coder` 用户（UID 1000）运行
- 配置了 sudo 无密码权限
- 支持 `--dangerously-skip-permissions` 参数

### 循环执行脚本

- `run-agent-loop.sh`：测试版本的循环执行脚本
- 自动创建 `agent_logs/` 目录
- 每次运行生成独立的日志文件（包含 commit hash 和时间戳）
- 支持 `--dangerously-skip-permissions` 参数

## 清理

```bash
# 停止并删除容器
docker-compose down

# 删除镜像
docker-compose down --rmi all

# 清理复制的配置
rm -rf .claude agent_logs

# 清理日志文件
rm -f /tmp/claude_test_output.txt /tmp/claude_skip_test.txt
```

## 预期结果

所有测试步骤都应该显示 ✓ 标记，表示测试通过。

如果测试失败，请检查：
- Docker 是否正常运行
- `.claude/` 配置是否存在于项目根目录
- `.env` 文件是否存在于项目根目录
- API key 是否配置正确
