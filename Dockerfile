FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    ca-certificates \
    iproute2 \
    iptables \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Add Cloudflare WARP repository
RUN curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | \
    gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/cloudflare-client.list

# Install Cloudflare WARP
RUN apt-get update && \
    apt-get install -y cloudflare-warp && \
    rm -rf /var/lib/apt/lists/*

# Copy startup script
COPY start-warp.sh /usr/local/bin/start-warp.sh
RUN chmod +x /usr/local/bin/start-warp.sh

# Expose any necessary ports (adjust as needed)
# EXPOSE 1080

CMD ["/usr/local/bin/start-warp.sh"]
