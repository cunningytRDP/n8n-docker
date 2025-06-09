# Use official n8n base image
FROM n8nio/n8n:latest

# Switch to root to install system packages
USER root

# Install required system packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    ffmpeg \
    git \
    curl \
    wget \
    jq \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install required Python libraries
RUN python3 -m pip install --upgrade pip && \
    pip3 install --no-cache-dir \
    whisper \
    moviepy \
    ffmpeg-python \
    pydub \
    openai \
    requests \
    transformers \
    torch \
    sentencepiece

# Optional: expose n8n HTTP port
EXPOSE 5678

# Switch back to n8n user
USER node

# Default command (Render runs CMD automatically)
CMD ["n8n"]
