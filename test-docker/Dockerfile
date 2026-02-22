FROM node:alpine3.23

# 安装必要的系统工具
RUN apk add --no-cache git bash curl sudo

# 安装 Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# 创建非 root 用户（用于支持 --dangerously-skip-permissions）
RUN addgroup -g 1000 coder && \
    adduser -D -u 1000 -G coder coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder

# 设置工作目录
WORKDIR /workspace

# 创建日志目录
RUN mkdir -p /workspace/agent_logs && chown -R coder:coder /workspace

# 切换到非 root 用户
USER coder

# 默认命令
CMD ["/bin/bash"]
