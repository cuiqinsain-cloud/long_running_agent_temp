# Long-Running Agent - Initializer Workspace

这是**长期运行代理架构**的初始化工作区。

## 架构说明

本项目实现了 Anthropic 文章《Effective harnesses for long-running agents》中提出的双代理架构：

- **Initializer Agent（初始化代理）**：负责项目环境搭建和需求拆分
- **Coding Agent（编码代理）**：负责增量式功能开发

两个代理通过不同的 `claude.md` 配置文件来约束行为，运行在不同的工作目录中。

## 快速开始

### 第一步：启动 Initializer Agent

```bash
cd initializer-workspace
claude
```

Claude  Code 会读取当前目录的 `claude.md`，自动成为 Initializer Agent。

### 第二步：需求讨论

Initializer Agent 会与你讨论项目需求：
- 项目类型和目标
- 技术栈选择
- 核心功能列表
- 测试策略
- 功能拆分粒度

**注意**：功能拆分的标准是"单个功能在一个 Coding session 内可完成"，而非追求特定数量。

### 第三步：环境创建

Initializer Agent 会在 `../coding-workspace/` 创建完整的开发环境：
- `claude.md` - Coding Agent 的行为配置
- `feature_list.json` - 功能清单（所有功能初始为 passes: false）
- `claude-progress.txt` - 进度日志
- `init.sh` - 项目启动脚本
- 项目代码框架
- Git 仓库

### 第四步：切换到 Coding Agent

```bash
cd ../coding-workspace
claude
```

Coding Agent 会自动：
1. 读取进度和功能列表
2. 运行健康检查
3. 选择一个功能开始实现
4. 测试完成后 git commit
5. 更新进度文件

## 上下文管理策略

### Initializer 阶段（预防）
- 拆分功能时评估复杂度
- 确保每个功能粒度合适
- 避免过于宽泛的功能描述

### Coding 阶段（监控）
- 实时自我监控上下文使用
- 发现功能过于复杂时，主动停止并拆分
- 通过 git commit 保存进度
- 必要时回滚到正常状态

## 文件说明

- `claude.md` - Initializer Agent 的配置文件（定义其行为和职责）
- `README.md` - 本说明文件

## 工作原理

1. **Claude  Code 启动时会读取当前目录的 `claude.md`**
2. `claude.md` 中的提示词定义了 agent 的角色和行为约束
3. 不同目录的 `claude.md` = 不同的 agent 行为
4. 通过文件（feature_list.json、progress.txt）+ Git 实现状态持久化
5. 每次新 session 都能快速恢复上下文并继续工作

## 参考资料

- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Agent SDK Quickstart](https://github.com/anthropics/claude-quickstarts/tree/main/autonomous-coding)
