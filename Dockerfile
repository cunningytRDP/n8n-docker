# Base: Slim Debian with Node 18
FROM debian:bullseye-slim

# Set environment variables
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=admin
ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    ffmpeg \
    git \
    curl \
    wget \
    jq \
    unzip \
    python3 \
    python3-pip \
    libsndfile1 \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install latest n8n
RUN npm install -g n8n

# Install Python packages
RUN pip3 install --no-cache-dir \
    numpy \
    pydub \
    moviepy \
    faster-whisper

# Setup Piper TTS
RUN mkdir -p /app/piper && \
    cd /app/piper && \
    wget https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz && \
    tar -xzf piper_linux_x86_64.tar.gz && \
    rm piper_linux_x86_64.tar.gz

# Optional: Copy your scripts
WORKDIR /app
COPY generate_video.py .
COPY generate_audio.sh .
RUN chmod +x generate_audio.sh

# Final working directory for n8n
WORKDIR /data

# Expose n8n's port
EXPOSE 5678

# Start n8n on container run
CMD ["n8n"]
