########################
# Stage 1 – Build Whisper & Python deps
########################
FROM python:3.10-slim AS whisper-builder

# System deps for Whisper
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg curl wget git unzip jq libsndfile1 libgl1 && \
    rm -rf /var/lib/apt/lists/*

# Install Whisper (OpenAI)
RUN pip install --upgrade pip && \
    pip install git+https://github.com/openai/whisper.git

########################
# Stage 2 – Final image with n8n + tools
########################
FROM node:18-slim

LABEL maintainer="you@example.com"

# ---------- 1. System packages ----------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg curl wget jq git unzip \
        python3 python3-pip libglib2.0-0 libsm6 libxrender1 libxext6 libsndfile1 && \
    rm -rf /var/lib/apt/lists/*

# ---------- 2. yt-dlp ----------
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
      -o /usr/local/bin/yt-dlp && \
    chmod 755 /usr/local/bin/yt-dlp

# ---------- 3. Piper TTS ----------
ENV PIPER_DIR=/opt/piper
RUN mkdir -p $PIPER_DIR && \
    curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
      | tar -xz -C $PIPER_DIR && \
    chmod 755 $PIPER_DIR/piper && \
    # Download a default English voice model (Lessac, medium)
    curl -L https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US-lessac-medium.onnx \
      -o $PIPER_DIR/en_US-lessac-medium.onnx && \
    chown -R node:node $PIPER_DIR
ENV PATH="$PIPER_DIR:$PATH"

# ---------- 4. n8n ----------
RUN npm install -g n8n

# ---------- 5. Whisper from Stage 1 ----------
COPY --from=whisper-builder /usr/local /usr/local

# ---------- 6. Non-root, port & cmd ----------
USER node
EXPOSE 5678
CMD ["n8n"]

########################
# End of Dockerfile
########################
