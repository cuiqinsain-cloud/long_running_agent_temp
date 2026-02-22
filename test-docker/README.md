# Docker 环境测试

此目录用于测试 Claude Code 在 Docker 容器中的运行情况。

## 测试内容

1. ✅ Docker 镜像构建
2. ✅ Claude Code CLI 安装
3. ✅ 配置文件挂载
4. ✅ git 工具安装
5. ✅ Claude Code 基本命令执行
6. ✅ Claude Code 交互响应

## 运行测试

```bash
cd test-docker
chmod +x test.sh
./test.sh
```

## 测试步骤

脚本会自动执行以下步骤：

1. 复制 `.claude/` 配置到测试目录
2. 构建 Docker 镜像
3. 启动容器
4. 验证 Claude Code CLI 安装
5. 检查版本信息
6. 验证配置文件存在
7. 验证 git 安装
8. 测试 Claude Code 基本命令
9. 测试 Claude Code 交互（发送 "say hi"）

## 手动测试

如果需要手动测试：

```bash
# 启动容器
docker-compose up -d

# 进入容器
docker-compose exec test-claude /bin/bash

# 在容器内测试
claude --version
claude

# 停止容器
docker-compose down
```

## 清理

```bash
# 停止并删除容器
docker-compose down

# 删除镜像
docker-compose down --rmi all

# 清理复制的配置
rm -rf .claude
```

## 预期结果

所有测试步骤都应该显示 ✓ 标记，表示测试通过。

如果测试失败，请检查：
- Docker 是否正常运行
- `.claude/` 配置是否存在于项目根目录
- API key 是否配置正确
