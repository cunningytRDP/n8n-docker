# Base image: lightweight Debian
FROM debian:bullseye-slim

# Set environment variables
ENV NODE_VERSION=18.20.2 \
    N8N_VERSION=1.48.0 \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    N8N_PORT=5678 \
    EXECUTIONS_PROCESS=main \
    N8N_HOST=0.0.0.0

# Install OS packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    git \
    python3 \
    python3-pip \
    ffmpeg \
    jq \
    ca-certificates \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js 18.x
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm

# Install n8n
RUN npm install -g n8n@$N8N_VERSION

# Install Python packages
RUN pip3 install --no-cache-dir \
    openai \
    whisper \
    moviepy \
    ffmpeg-python \
    pydub \
    transformers \
    torch \
    sentencepiece \
    requests

# Set working directory
WORKDIR /data

# Create default .n8n directory (for Render disk mount)
RUN mkdir -p /home/node/.n8n

# Expose n8n default port
EXPOSE 5678

# Set entrypoint
CMD ["n8n"]
