FROM n8nio/n8n:latest-debian

USER root

RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    wget \
    jq \
    python3 \
    python3-pip \
    unzip \
    libsndfile1 \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip
RUN pip3 install numpy pydub moviepy faster-whisper

RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && chmod a+rx /usr/local/bin/yt-dlp

RUN mkdir -p /opt/piper \
 && wget -q https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
 && tar -xzf piper_linux_x86_64.tar.gz -C /opt/piper \
 && chmod +x /opt/piper/piper \
 && ln -s /opt/piper/piper /usr/local/bin/piper \
 && rm piper_linux_x86_64.tar.gz

USER node

ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=admin
