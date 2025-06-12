FROM n8nio/n8n:latest-debian

USER root

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    ffmpeg \
    libsm6 \
    libxext6 \
    git \
    curl \
    wget \
    jq \
    python3 \
    python3-pip \
    unzip \
    libsndfile1 \
    python3-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip (some packages need latest pip to install cleanly)
RUN pip3 install --upgrade pip

# Install lightweight Python dependencies
RUN pip3 install numpy pydub moviepy

# Install Torch separately using stable CPU wheel
RUN pip3 install torch==2.1.0+cpu torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install Whisper separately (after torch is installed)
RUN pip3 install openai-whisper

# Install yt-dlp
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
 && chmod a+rx /usr/local/bin/yt-dlp

# Install Piper binary
RUN mkdir -p /opt/piper \
 && wget -q https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
 && tar -xzf piper_linux_x86_64.tar.gz -C /opt/piper \
 && chmod +x /opt/piper/piper \
 && ln -s /opt/piper/piper /usr/local/bin/piper \
 && rm piper_linux_x86_64.tar.gz

# Set path
ENV PATH="/usr/local/bin:$PATH"

# Switch back to non-root
USER node

# Optional n8n environment
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=admin
ENV N8N_PORT=5678
ENV N8N_HOST=0.0.0.0
ENV WEBHOOK_TUNNEL_URL=https://n8n-docker-hnnu.onrender.com
