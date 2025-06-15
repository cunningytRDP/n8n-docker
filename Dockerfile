# Start from a lightweight Debian base with Node.js
FROM node:18-slim

# Environment setup
ENV N8N_USER_FOLDER="/home/node/.n8n"
ENV N8N_HOST="localhost"
ENV N8N_PORT=5678
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    wget \
    git \
    jq \
    unzip \
    build-essential \
    libsndfile1 \
    python3 \
    python3-pip \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Fix Python alias
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install yt-dlp
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod a+rx /usr/local/bin/yt-dlp

# Install Whisper for transcription
RUN pip install --no-cache-dir git+https://github.com/openai/whisper.git

# Install Piper TTS for voice synthesis
RUN mkdir -p /opt/piper && \
    curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz | tar -xz -C /opt/piper && \
    chmod +x /opt/piper/piper

ENV PATH="/opt/piper:$PATH"

# Install n8n
RUN npm install --global n8n

# Create n8n data directory and set permissions
RUN mkdir -p $N8N_USER_FOLDER && chown -R node:node $N8N_USER_FOLDER

# Use non-root user
USER node

# Expose the default port
EXPOSE 5678

# Launch n8n
CMD ["n8n"]
