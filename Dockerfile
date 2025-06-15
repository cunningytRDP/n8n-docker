FROM node:18-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=admin

Install system dependencies 

RUN apt-get update && apt-get install -y \
python3 \
python3-pip \
ffmpeg \
git \
curl \
wget \
jq \
unzip \
build-essential \
libsndfile1 \
libgl1 \
libsm6 \
libxext6 \
libglib2.0-0 \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

Install Python dependencies (correct syntax) 

RUN pip3 install --upgrade pip && \
pip3 install numpy==1.24.4 pydub==0.25.1 moviepy==1.0.3 faster-whisper==0.10.0

Install n8n 

RUN npm install -g n8n

Install Piper TTS 

RUN mkdir -p /app/piper && \
cd /app/piper && \
wget https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz && \
tar -xzf piper_linux_x86_64.tar.gz && \
rm piper_linux_x86_64.tar.gz

Set working directory 

WORKDIR /data

Expose port 

EXPOSE 5678

Start n8n 

CMD ["n8n"]

