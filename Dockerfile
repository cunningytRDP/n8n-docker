# Use Node base with Debian for compatibility
FROM node:18-bullseye

# Environment variables (can be overridden in Render Dashboard)
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=secret
ENV N8N_PORT=10000
ENV WEBHOOK_URL=https://your-subdomain.onrender.com/
ENV EXECUTIONS_MODE=queue
ENV DB_SQLITE_VACUUM_ON_STARTUP=true

# Set working directory
WORKDIR /app

# Install system dependencies
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

# Alias python3 to python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install n8n
RUN npm install -g n8n

# Upgrade pip and install Python packages
RUN pip install --upgrade pip && \
    pip install moviepy pydub yt-dlp openai-whisper whisper-timestamped && \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Download and extract Piper TTS binary
RUN mkdir -p /piper && \
    cd /piper && \
    wget --no-verbose https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz -O piper.tar.gz && \
    tar -xzf piper.tar.gz && \
    rm piper.tar.gz && \
    chmod +x /piper/piper

# Expose Render default port
EXPOSE 10000

# Default command to run n8n
CMD ["n8n"]
