# Start from a lightweight Debian base
FROM node:18-slim

# Set environment variables
ENV N8N_USER_FOLDER="/home/node/.n8n"
ENV N8N_HOST="localhost"
ENV N8N_PORT=5678
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Install system packages
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    wget \
    git \
    jq \
    unzip \
    build-essential \
    libsndfile1 \
    python3 \
    python3-pip \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install yt-dlp (for YouTube and video downloads)
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod a+rx /usr/local/bin/yt-dlp

# Set Python aliases
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Whisper (for transcriptions)
RUN pip install --no-cache-dir git+https://github.com/openai/whisper.git

# Install Piper TTS (voice generation)
RUN mkdir -p /opt/piper && \
    curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz | tar -xz -C /opt/piper && \
    chmod +x /opt/piper/piper

# Add Piper to PATH
ENV PATH="/opt/piper:$PATH"

# Install n8n
RUN npm install --global n8n

# Create n8n data folder
RUN mkdir -p $N8N_USER_FOLDER && chown -R node:node $N8N_USER_FOLDER

# Switch to non-root user
USER node

# Expose default n8n port
EXPOSE 5678

# Start n8n
CMD ["n8n"]
