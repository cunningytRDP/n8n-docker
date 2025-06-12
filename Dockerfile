# Use Debian-based n8n image so apt-get works
FROM n8nio/n8n:latest-debian

# Switch to root to install packages
USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    curl \
    wget \
    jq \
    python3 \
    python3-pip \
    unzip \
    libsndfile1 \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir \
    openai-whisper \
    moviepy \
    pydub \
    numpy \
    torch

# Install yt-dlp
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
 && chmod a+rx /usr/local/bin/yt-dlp

# Install Piper TTS binary
RUN mkdir -p /opt/piper \
 && wget -q https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
 && tar -xzf piper_linux_x86_64.tar.gz -C /opt/piper \
 && chmod +x /opt/piper/piper \
 && ln -s /opt/piper/piper /usr/local/bin/piper \
 && rm piper_linux_x86_64.tar.gz

# Set env path
ENV PATH="/usr/local/bin:$PATH"

# Switch back to node user
USER node

# Optional: Set up auth
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=admin
ENV N8N_PORT=5678
ENV N8N_HOST=0.0.0.0
ENV WEBHOOK_TUNNEL_URL=https://your-subdomain.onrender.com
