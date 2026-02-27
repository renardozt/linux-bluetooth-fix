#!/bin/bash

echo "🎧 Installing Linux Bluetooth Audio Keepalive Fix..."

# Define paths
SCRIPT_NAME="bluetooth_keepalive.sh"
BIN_DIR="$HOME/.local/bin"
SYSTEMD_DIR="$HOME/.config/systemd/user"
SERVICE_NAME="bluetooth-keepalive.service"
SERVICE_PATH="$SYSTEMD_DIR/$SERVICE_NAME"

# 1. Check if the main script exists in the current directory
if [ ! -f "$SCRIPT_NAME" ]; then
    echo "❌ Error: '$SCRIPT_NAME' not found in the current directory."
    echo "Please run this installer from the directory containing the script."
    exit 1
fi

# 2. Setup binary directory and copy the script
echo "📁 Copying script to $BIN_DIR..."
mkdir -p "$BIN_DIR"
cp "$SCRIPT_NAME" "$BIN_DIR/"
chmod +x "$BIN_DIR/$SCRIPT_NAME"

# 3. Create the systemd user service file
echo "⚙️ Creating systemd user service..."
mkdir -p "$SYSTEMD_DIR"

cat <<EOF > "$SERVICE_PATH"
[Unit]
Description=Bluetooth Audio Keepalive Service
After=pulseaudio.service pipewire-pulse.service

[Service]
ExecStart=$BIN_DIR/$SCRIPT_NAME
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

# 4. Reload systemd, enable, and start the service
echo "🚀 Enabling and starting the background service..."
systemctl --user daemon-reload
systemctl --user enable --now "$SERVICE_NAME"

# 5. Verify the service status
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    echo ""
    echo "✅ SUCCESS! The Bluetooth keepalive service is now running in the background."
    echo "It will automatically start every time you log in."
    echo ""
    echo "📊 Useful Commands:"
    echo " - Check status: systemctl --user status $SERVICE_NAME"
    echo " - View logs:    tail -f ~/.bluetooth_reconnect.log"
    echo " - Stop service: systemctl --user disable --now $SERVICE_NAME"
else
    echo ""
    echo "⚠️ The service was installed but might not be active."
    echo "Please check its status using: systemctl --user status $SERVICE_NAME"
fi
