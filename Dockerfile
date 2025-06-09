FROM debian:bullseye-slim

USER root

RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    python3-pip \
    ffmpeg \
    jq \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm n8n

RUN pip3 install --no-cache-dir \
    whisper \
    moviepy \
    ffmpeg-python \
    pydub \
    transformers \
    torch \
    sentencepiece \
    requests

EXPOSE 5678

CMD ["n8n"]
