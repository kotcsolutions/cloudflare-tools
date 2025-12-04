#!/bin/bash
set -e

echo "Starting Cloudflare WARP Connector..."

# Enable IP forwarding
echo "Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Start the WARP service in the background
echo "Starting warp-svc daemon..."
warp-svc &
WARP_SVC_PID=$!

# Wait for the daemon to be ready
echo "Waiting for warp-svc to be ready..."
sleep 5

# Check if we need to register the connector
if [ ! -z "$WARP_CONNECTOR_TOKEN" ]; then
    echo "Registering connector with token..."
    warp-cli connector new "$WARP_CONNECTOR_TOKEN" || echo "Connector already registered or error occurred"
else
    echo "No WARP_CONNECTOR_TOKEN provided, skipping registration"
fi

# Connect to WARP
echo "Connecting to WARP..."
warp-cli connect || echo "Already connected or error occurred"

# Show connection status
echo "WARP Status:"
warp-cli status || true

echo "WARP Connector is running. Logs will appear below..."

# Keep the container running and monitor the daemon
trap "echo 'Shutting down...'; warp-cli disconnect; kill $WARP_SVC_PID; exit 0" SIGTERM SIGINT

# Tail logs and keep container alive
wait $WARP_SVC_PID
