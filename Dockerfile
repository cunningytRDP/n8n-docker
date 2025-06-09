# Base image with Debian + Node + npm + Python support
FROM node:18-bullseye

# Set environment vars
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=secret

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

# Make 'python' alias
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install global npm dependencies
RUN npm install -g n8n

# Install Python packages
RUN pip install --upgrade pip && pip install \
    openai-whisper \
    whisper-timestamped \
    moviepy \
    pydub \
    yt-dlp \
    TTS==0.22.0 \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install Piper TTS (C++ binary)
RUN mkdir -p /piper && \
    wget -q https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz -O - | tar -xz -C /piper && \
    chmod +x /piper/piper

# Expose n8n default port
EXPOSE 5678

# Default command to run n8n
CMD ["n8n"]
