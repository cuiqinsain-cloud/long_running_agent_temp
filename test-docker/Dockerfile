FROM node:alpine3.23

# 安装必要的系统工具
RUN apk add --no-cache git bash curl

# 安装 Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# 设置工作目录
WORKDIR /workspace

# 默认命令
CMD ["/bin/bash"]
