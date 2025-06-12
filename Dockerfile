# Use Debian base for full apt compatibility
FROM node:18-bullseye-slim

# Set working directory
WORKDIR /usr/src/app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    curl \
    wget \
    jq \
    unzip \
    python3 \
    python3-pip \
    libsndfile1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir \
    numpy \
    pydub \
    moviepy \
    faster-whisper

# Install Piper TTS binary
RUN mkdir -p /piper && \
    curl -Lo /piper/piper https://huggingface.co/rhasspy/piper/resolve/main/linux/x86_64/piper && \
    chmod +x /piper/piper && \
    ln -s /piper/piper /usr/local/bin/piper

# Install n8n globally
RUN npm install -g n8n

# Switch to existing non-root user "node"
USER node

# Expose default n8n port
EXPOSE 5678

# Set timezone
ENV TZ=Asia/Kolkata

# Start n8n
CMD ["n8n"]
