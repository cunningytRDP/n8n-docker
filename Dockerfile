# -------- Stage 1: Build Whisper + Python deps --------
FROM python:3.10-slim as whisper-builder

# Install system deps
# Install system dependencies (with full Python support)
RUN apt-get update && apt-get install -y \
    curl wget git unzip ffmpeg jq \
    python3 python3-pip python3-venv libpython3.10 libpython3.10-dev libsndfile1 \
 && ln -sf /usr/bin/python3 /usr/bin/python \
 && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install whisper + torch (CPU)
RUN pip install --upgrade pip && \
    pip install --no-cache-dir \
      torch==2.1.2+cpu \
      torchvision==0.16.2+cpu \
      torchaudio==2.1.2+cpu \
      --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir git+https://github.com/openai/whisper.git

# -------- Stage 2: Final n8n image --------
FROM node:18-slim

# Basic envs
ENV N8N_USER_FOLDER="/home/node/.n8n"
ENV NODE_ENV=production
ENV PATH="/opt/piper:$PATH"

# Create app dir
WORKDIR /app

# Install system tools
RUN apt-get update && apt-get install -y \
    ffmpeg curl wget git jq unzip libsndfile1 python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Python deps and whisper from builder
COPY --from=whisper-builder /usr/local/lib/python3.10 /usr/local/lib/python3.10
COPY --from=whisper-builder /usr/local/bin /usr/local/bin

# Install yt-dlp
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /usr/local/bin/yt-dlp && chmod +x /usr/local/bin/yt-dlp

# Install Piper
RUN mkdir -p /opt/piper && \
    curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
    | tar -xz -C /opt/piper && chmod +x /opt/piper/piper

# Install n8n
RUN npm install --global n8n

# Setup n8n directory
RUN mkdir -p $N8N_USER_FOLDER && chown -R node:node $N8N_USER_FOLDER

# Use non-root user
USER node

EXPOSE 5678
CMD ["n8n"]
