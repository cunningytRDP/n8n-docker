# Start from the official n8n image
FROM n8nio/n8n

# Switch to the root user to install system-level packages
USER root

# Update package lists and install ffmpeg and other dependencies for Piper TTS
# espeak-ng is a dependency for Piper
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    espeak-ng \
    && rm -rf /var/lib/apt/lists/*

# Switch back to the node user
USER node

# Create a directory for Python packages
RUN mkdir -p /home/node/.local/bin
ENV PATH="/home/node/.local/bin:${PATH}"

# Upgrade pip and install the specified Python packages using a requirements.txt file
# We will create this file next.
COPY --chown=node:node requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# This command will be run when the container starts.
# It's the default command for the n8n container.
CMD [ "n8n" ]
