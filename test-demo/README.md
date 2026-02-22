# Coding Agent 自动化测试

测试 Coding Agent 在 Docker 容器内自动完成所有开发任务。

## 测试内容

1. 预设 TODO CLI 项目结构
2. 在 Docker 容器内自动循环执行 Coding Agent
3. 验证所有功能是否完成

## 使用方法

```bash
./test.sh
```

## 测试流程

1. **环境检查** - Docker、.env、API Token
2. **创建预设项目** - feature_list.json、CLAUDE.md、Dockerfile 等
3. **构建 Docker 镜像** - 包含 Python、Git、Claude CLI
4. **验证容器环境** - 确保所有工具可用
5. **自动循环执行** - Coding Agent 自动完成所有功能
6. **验证结果** - 检查功能状态、Git 提交、日志

## 预设项目

**TODO CLI 工具**（3个功能）：
- F001: 添加 TODO 项
- F002: 列出所有 TODO 项
- F003: 标记 TODO 为完成

## 文件说明

- `test.sh` - 主测试脚本
- `agent-loop.sh` - 容器内循环执行脚本
- `README.md` - 本文档

## 清理

测试完成后根据提示选择自动或手动清理。
