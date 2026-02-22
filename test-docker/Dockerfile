FROM node:alpine3.23

# 安装必要的系统工具
RUN apk add --no-cache git bash curl sudo

# 安装 Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# 使用现有的 node 用户（UID 1000，GID 1000）并重命名为 coder
# Alpine node 镜像已经创建了 node:x:1000:node 用户
RUN deluser --remove-home node && \
    addgroup -g 1000 coder && \
    adduser -D -u 1000 -G coder coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder && \
    chmod 0440 /etc/sudoers.d/coder

# 设置工作目录
WORKDIR /workspace

# 创建日志目录并设置权限
RUN mkdir -p /workspace/agent_logs && chown -R coder:coder /workspace

# 切换到非 root 用户
USER coder

# 默认命令
CMD ["/bin/bash"]
