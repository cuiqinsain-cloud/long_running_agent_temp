# Docker 环境测试

此目录用于测试 Claude Code 在 Docker 容器中的运行情况。

## 快速开始

### 1. 初始化环境

```bash
cd test-docker
./init-env.sh
```

这个脚本会：
- 复制 `.claude/` 配置
- 复制 `.env` 环境变量
- 构建 Docker 镜像
- 启动容器
- 验证基本配置

### 2. 进入容器交互

```bash
# 进入容器 bash
docker-compose exec test-claude /bin/bash

# 在容器内运行 Claude Code（手动模式）
claude

# 或者运行循环脚本（自动连续处理）
./run-agent-loop.sh
```

### 3. 监控日志

```bash
./monitor-logs.sh
```

提供三种监控模式：
1. 容器日志（docker-compose logs）
2. Agent 运行日志（agent_logs/）
3. 同时监控容器和最新 agent 日志

### 4. 清理环境

```bash
./cleanup.sh
```

提供三种清理级别：
1. 轻度清理：停止容器，保留镜像和配置
2. 中度清理：停止并删除容器，保留镜像
3. 完全清理：删除容器、镜像、配置、日志

## 测试内容

✅ Docker 镜像构建
✅ Claude Code CLI 安装
✅ 配置文件挂载
✅ git 工具安装
✅ 非 root 用户配置（coder）
✅ sudo 权限配置
✅ 循环执行脚本
✅ Claude Code 基本命令执行
✅ Claude Code 交互响应
✅ --dangerously-skip-permissions 参数测试

## 脚本说明

### init-env.sh
初始化脚本，用于创建测试环境并启动容器。

**功能**：
- 复制配置文件
- 构建 Docker 镜像
- 启动容器
- 验证基本配置

**使用**：
```bash
./init-env.sh
```

### monitor-logs.sh
日志监控脚本，实时查看容器和 agent 运行日志。

**功能**：
- 查看容器日志
- 查看 agent 运行日志
- 同时监控多个日志源

**使用**：
```bash
./monitor-logs.sh
# 然后选择监控模式 [1-3]
```

### cleanup.sh
环境清理脚本，停止容器并清理相关文件。

**功能**：
- 轻度清理：停止容器
- 中度清理：删除容器
- 完全清理：删除所有相关文件

**使用**：
```bash
./cleanup.sh
# 然后选择清理级别 [1-3]
```

### run-agent-loop.sh
循环执行脚本（在容器内运行），让 Claude Code 持续处理任务。

**功能**：
- 自动连续处理多个功能
- 每次运行生成独立日志文件
- 支持 --dangerously-skip-permissions 参数

**使用**：
```bash
# 在容器内执行
./run-agent-loop.sh
```

### test.sh
完整的自动化测试脚本（原有脚本，保留用于 CI/CD）。

**功能**：
- 自动执行所有测试步骤
- 验证所有功能是否正常

**使用**：
```bash
./test.sh
```

## 容器内操作

进入容器后，你可以：

```bash
# 查看当前用户
whoami  # 应该显示 coder

# 查看 Claude Code 版本
claude --version

# 手动运行 Claude Code
claude

# 运行循环脚本（无人值守）
./run-agent-loop.sh

# 查看生成的日志
ls -lh agent_logs/

# 查看最新日志
tail -f agent_logs/agent_*.log
```

## 目录结构

```
test-docker/
├── Dockerfile              # Docker 镜像定义
├── docker-compose.yml      # 容器编排配置
├── init-env.sh            # 初始化脚本
├── monitor-logs.sh        # 日志监控脚本
├── cleanup.sh             # 清理脚本
├── run-agent-loop.sh      # 循环执行脚本（容器内）
├── test.sh                # 自动化测试脚本
├── README.md              # 本文档
├── .claude/               # Claude Code 配置（运行时复制）
├── .env                   # 环境变量（运行时复制）
└── agent_logs/            # Agent 运行日志（运行时生成）
```

## 技术特性

### 非 root 用户支持
- 容器使用 `coder` 用户（UID 1000）运行
- 配置了 sudo 无密码权限
- 支持 `--dangerously-skip-permissions` 参数

### 循环执行模式
- 自动创建 `agent_logs/` 目录
- 每次运行生成独立的日志文件（包含 commit hash 和时间戳）
- 支持无人值守连续开发

### Volume 挂载
- 代码文件在宿主机和容器间实时同步
- Git 配置挂载到容器内
- 日志文件可在宿主机直接查看

## 常见问题

**Q: 如何停止循环脚本？**
A: 在容器内按 `Ctrl+C`

**Q: 如何查看历史日志？**
A: 运行 `./monitor-logs.sh` 选择模式 2，或直接查看 `agent_logs/` 目录

**Q: 如何重新构建镜像？**
A: 运行 `./cleanup.sh` 选择完全清理，然后重新运行 `./init-env.sh`

**Q: 容器启动失败怎么办？**
A: 检查 Docker 是否运行，`.claude/` 和 `.env` 是否存在于项目根目录

## 工作流程示例

```bash
# 1. 初始化环境
./init-env.sh

# 2. 在另一个终端监控日志
./monitor-logs.sh

# 3. 进入容器开始工作
docker-compose exec test-claude /bin/bash

# 4. 在容器内运行 Claude Code
claude
# 或运行循环脚本
./run-agent-loop.sh

# 5. 完成后清理环境
./cleanup.sh
```

## 注意事项

- 确保 Docker 正常运行
- 确保项目根目录有 `.claude/` 配置
- 确保项目根目录有 `.env` 文件并配置了 `ANTHROPIC_AUTH_TOKEN`
- 循环模式下，日志文件会持续增长，注意磁盘空间
