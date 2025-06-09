# Base image
FROM node:18-bullseye

# Environment
ENV N8N_PORT=10000
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=secret
ENV WEBHOOK_URL=https://your-subdomain.onrender.com/

# Set working directory
WORKDIR /app

# Install system packages
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    curl \
    wget \
    jq \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    libsndfile1 \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Alias python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install n8n
RUN npm install -g n8n

# Upgrade pip
RUN pip install --upgrade pip

# Install Python packages one at a time to avoid dependency clashes
RUN pip install torch==2.2.2 torchvision==0.17.2 torchaudio==2.2.2 --index-url https://download.pytorch.org/whl/cpu
RUN pip install openai-whisper==20231117 whisper-timestamped==1.14
RUN pip install yt-dlp==2024.04.09
RUN pip install moviepy==1.0.3 pydub==0.25.1

# Install Piper binary
RUN mkdir -p /piper && \
    cd /piper && \
    curl -L -o piper.tar.gz https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz && \
    tar -xzf piper.tar.gz && \
    rm piper.tar.gz && \
    chmod +x /piper/piper

# Expose n8n port
EXPOSE 10000

# Sta
