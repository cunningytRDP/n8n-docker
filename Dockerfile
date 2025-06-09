FROM n8nio/n8n:latest

# Install dependencies
USER root

# Install ffmpeg, yt-dlp, Python, Whisper dependencies, jq, curl, wget
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

# Make Python available as 'python'
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Python packages for AI agents
RUN pip install --upgrade pip && \
    pip install \
    openai-whisper \
    whisper-timestamped \
    pydub \
    moviepy \
    yt-dlp \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu \
    TTS==0.22.0  # For Piper-compatible TTS, optional

# Optional: install Piper TTS binaries (small English model)
RUN mkdir -p /piper && \
    wget -q https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz -O - | tar -xz -C /piper && \
    chmod +x /piper/piper

# Set permissions
RUN chown -R node:node /piper

# Switch back to n8n user
USER node

# Set working dir
WORKDIR /data

# Default n8n command
CMD ["n8n"]
