FROM python:3.10-slim

# Set environment variables
ENV PIP_NO_CACHE_DIR=1
ENV DEBIAN_FRONTEND=noninteractive
ENV N8N_USER_FOLDER="/home/node/.n8n"
ENV NODE_ENV=production
ENV PATH="/opt/piper:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl wget git unzip ffmpeg jq build-essential libsndfile1 ca-certificates gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Install Node.js (18.x) and npm ---
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g n8n

# --- Install yt-dlp (standalone) ---
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /usr/local/bin/yt-dlp && chmod +x /usr/local/bin/yt-dlp

# --- Install Whisper and Torch (CPU) ---
RUN pip install --upgrade pip && \
    pip install torch==2.1.2+cpu torchvision==0.16.2+cpu torchaudio==2.1.2+cpu \
      --index-url https://download.pytorch.org/whl/cpu && \
    pip install git+https://github.com/openai/whisper.git

# --- Install Piper ---
RUN mkdir -p /opt/piper && \
    curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
    | tar -xz -C /opt/piper && chmod +x /opt/piper/piper

# Create n8n data directory
RUN useradd -m node && mkdir -p $N8N_USER_FOLDER && chown -R node:node $N8N_USER_FOLDER
USER node

EXPOSE 5678
CMD ["n8n"]
