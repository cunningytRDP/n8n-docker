FROM node:18-slim

ENV N8N_USER_FOLDER="/home/node/.n8n"
ENV NODE_ENV=production

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
  ffmpeg curl wget git jq unzip build-essential \
  libsndfile1 python3 python3-pip ca-certificates \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Fix Python alias
RUN ln -s /usr/bin/python3 /usr/bin/python

# yt-dlp
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
  -o /usr/local/bin/yt-dlp && chmod +x /usr/local/bin/yt-dlp

# Install Python requirements
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Install Piper
RUN mkdir -p /opt/piper && \
    curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz \
    | tar -xz -C /opt/piper && chmod +x /opt/piper/piper
ENV PATH="/opt/piper:$PATH"

# Install n8n
RUN npm install --global n8n

# Final permissions
RUN mkdir -p $N8N_USER_FOLDER && chown -R node:node $N8N_USER_FOLDER

USER node
EXPOSE 5678
CMD ["n8n"]
