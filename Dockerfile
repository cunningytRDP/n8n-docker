FROM node:18-bullseye

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    python3 \
    python3-pip \
    curl \
    wget \
    git \
    jq \
    build-essential \
    libsndfile1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python tools
RUN pip3 install --no-cache-dir yt-dlp openai-whisper

# Download and install Piper (voice synthesis)
RUN mkdir -p /app/piper && \
    curl -Lo /app/piper/piper https://github.com/rhasspy/piper/releases/download/v1.2.0/piper-linux-x86_64 && \
    chmod +x /app/piper/piper && \
    curl -Lo /app/piper/en_US-amy-low.onnx https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy-low/en_US-amy-low.onnx && \
    curl -Lo /app/piper/en_US-amy-low.onnx.json https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy-low/en_US-amy-low.onnx.json

# Add piper binary to PATH
ENV PATH="/app/piper:$PATH"

# Install n8n globally
RUN npm install -g n8n

# Expose default n8n port
EXPOSE 5678

# Start n8n when container launches
CMD ["n8n"]
