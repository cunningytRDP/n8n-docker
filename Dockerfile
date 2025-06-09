FROM node:18-bullseye

ENV N8N_PORT=10000
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=secret
ENV WEBHOOK_URL=https://your-subdomain.onrender.com/

WORKDIR /app

# Install base system dependencies
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

# Install n8n globally
RUN npm install -g n8n

# Setup Python virtual environment
RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Upgrade pip safely
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install Torch + Whisper + moviepy + yt-dlp + Piper dependencies
RUN pip install --no-cache-dir \
    torch==2.2.2 \
    torchvision==0.17.2 \
    torchaudio==2.2.2 \
    --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir \
    openai-whisper \
    whisper-timestamped \
    yt-dlp \
    moviepy==1.0.3 \
    pydub==0.25.1

# Download Piper binary
RUN mkdir -p /piper && \
    cd /piper && \
    curl -L -o piper.tar.gz https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz && \
    tar -xzf piper.tar.gz && \
    rm piper.tar.gz && \
    chmod +x /piper/piper

# Expose port
EXPOSE 10000

# Run n8n
CMD ["n8n"]
