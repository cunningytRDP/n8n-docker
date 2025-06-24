# -------- Stage 1: Build Whisper + Python deps --------
FROM python:3.10-slim as whisper-builder

RUN apt-get update && apt-get install -y \
    curl wget git unzip ffmpeg jq \
    python3 python3-pip python3-venv libsndfile1 libgl1 \
 && pip install --upgrade pip && \
    pip install git+https://github.com/openai/whisper.git

# -------- Stage 2: Main n8n with custom tools --------
FROM n8nio/n8n:latest

# Install system dependencies
USER root
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

# Install Whisper from previous stage
COPY --from=whisper-builder /usr/local/lib/python3.10 /usr/local/lib/python3.10
COPY --from=whisper-builder /usr/local/bin /usr/local/bin

# Install Piper TTS
RUN mkdir -p /opt/piper && \
    curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
    | tar -xz -C /opt/piper && \
    chmod +x /opt/piper/piper

ENV PATH="/opt/piper:$PATH"

# Fix permissions
USER node
