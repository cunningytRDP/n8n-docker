FROM node:18-slim

ENV N8N_USER_FOLDER="/home/node/.n8n"
ENV NODE_ENV=production

WORKDIR /app

# Install system packages
RUN apt-get update && apt-get install -y \
    ffmpeg curl wget git jq unzip build-essential \
    libsndfile1 python3 python3-pip ca-certificates \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Alias `python` to `python3`
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install yt-dlp
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /usr/local/bin/yt-dlp && chmod +x /usr/local/bin/yt-dlp

# Install PyTorch CPU-only (correct index usage)
RUN pip install --upgrade pip && \
    pip install --no-cache-dir \
      torch==2.1.2+cpu \
      torchvision==0.16.2+cpu \
      torchaudio==2.1.2+cpu \
      --index-url https://download.pytorch.org/whl/cpu

# Install Whisper separately to avoid builder crashes
RUN pip install --no-cache-dir git+https://github.com/openai/whisper.git

# Install Piper TTS binary (latest Linux release)
RUN mkdir -p /opt/piper && \
    curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
    | tar -xz -C /opt/piper && chmod +x /opt/piper/piper

ENV PATH="/opt/piper:$PATH"

# Install n8n globally
RUN npm install --global n8n

# Prepare the n8n user directory
RUN mkdir -p $N8N_USER_FOLDER && chown -R node:node $N8N_USER_FOLDER

# Switch to non-root user
USER node

EXPOSE 5678
CMD ["n8n"]
