# Use Node 18 base image with Debian
FROM node:18-slim

# Set environment variables
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=admin
ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# Install all required system packages
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
    build-essential \
    libx264-dev \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libgl1-mesa-glx \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install --no-cache-dir \
    numpy \
    pydub \
    moviepy==1.0.3 \
    faster-whisper==0.10.0

# Install n8n
RUN npm install -g n8n

# Install Piper TTS (optional voice generation)
RUN mkdir -p /app/piper && \
    cd /app/piper && \
    wget https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz && \
    tar -xzf piper_linux_x86_64.tar.gz && \
    rm piper_linux_x86_64.tar.gz

# Set working directory for n8n
WORKDIR /data

# Expose n8n port
EXPOSE 5678

# Start n8n on container run
CMD ["n8n"]
