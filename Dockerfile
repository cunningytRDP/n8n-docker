# -------- Stage 1: Build Whisper + Python deps --------
FROM python:3.10-slim as whisper-builder

RUN apt-get update && apt-get install -y \
    curl wget git unzip ffmpeg jq \
    python3 python3-pip python3-venv libsndfile1 libgl1 \
 && pip install --upgrade pip && \
    pip install git+https://github.com/openai/whisper.git

# -------- Stage 2: Main n8n on Debian with all tools --------
FROM node:18-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    wget \
    jq \
    git \
    unzip \
    python3 \
    python3-pip \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libsndfile1 \
 && rm -rf /var/lib/apt/lists/*

# Install yt-dlp
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp

# Install Piper TTS
RUN mkdir -p /opt/piper && \
    curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
    | tar -xz -C /opt/piper && \
    chmod 755 /opt/piper/piper && \
    chown -R node:node /opt/piper


# Install n8n globally
RUN npm install -g n8n

# Copy Whisper from Stage 1
COPY --from=whisper-builder /usr/local /usr/local

# Set PATH to include piper
ENV PATH="/opt/piper:$PATH"

# Switch to the pre-existing non-root node user
USER node

# Set default port
EXPOSE 5678

# Start n8n
CMD ["n8n"]
