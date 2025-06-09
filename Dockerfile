FROM node:18-bullseye

ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=secret

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

# Make python alias
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install global n8n
RUN npm install -g n8n

# Upgrade pip separately
RUN pip install --upgrade pip

# Install light Python dependencies first
RUN pip install moviepy pydub yt-dlp whisper-timestamped

# Install whisper (CPU)
RUN pip install openai-whisper

# Install torch separately (CPU only)
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Optional: skip installing Coqui TTS if using Piper directly
# RUN pip install TTS==0.22.0

# Install Piper (C++ binary) – lightweight and fast
RUN mkdir -p /piper && \
    wget -q https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz -O - | tar -xz -C /piper && \
    chmod +x /piper/piper

# Expose port
EXPOSE 5678

CMD ["n8n"]
