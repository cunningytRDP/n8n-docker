FROM n8nio/n8n:latest

# Install OS-level dependencies
USER root
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    curl \
    wget \
    jq \
    unzip \
    python3 \
    python3-pip \
    libsndfile1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install Python libraries
RUN pip3 install --no-cache-dir \
    numpy \
    pydub \
    moviepy \
    faster-whisper

# Install Piper TTS (lightweight voice engine)
RUN mkdir -p /piper && \
    curl -Lo /piper/piper https://huggingface.co/rhasspy/piper/resolve/main/linux/x86_64/piper && \
    chmod +x /piper/piper && \
    ln -s /piper/piper /usr/local/bin/piper

# Set back to n8n user
USER node

# Expose port
EXPOSE 5678

# Start n8n
CMD ["n8n"]
