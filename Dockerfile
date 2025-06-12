# Base image with Node.js 18 (safe for n8n 1.45.0)
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

# Install Python libraries
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

# Install yt-dlp
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
    chmod +x /usr/local/bin/yt-dlp

# Install n8n (compatible version!)
RUN npm install -g n8n@1.45.0

# Set environment variables
ENV N8N_PORT=5678
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=admin
ENV TZ=Asia/Kolkata

# Use the default non-root user
USER node

# Expose the port used by n8n
EXPOSE 5678

# Start n8n
ENTRYPOINT ["n8n"]
