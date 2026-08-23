FROM node:22-bookworm

RUN apt update && apt install -y \
    git \
    curl \
    ripgrep \
    python3 \
    build-essential

RUN npm install -g \
    pnpm \
    @anthropic-ai/claude-code \
    opencode-ai

WORKDIR /workspace

USER node