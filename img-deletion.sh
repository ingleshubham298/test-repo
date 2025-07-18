#!/bin/bash

CLEANUP_SCRIPT="$HOME/docker_image_cleanup.sh"

# Create the Docker cleanup script in user's home
echo "Creating Docker cleanup script at $CLEANUP_SCRIPT..."

cat > "$CLEANUP_SCRIPT" << 'EOF'
#!/bin/bash
docker images -q | xargs -r docker rmi -f
EOF

chmod +x "$CLEANUP_SCRIPT"

# Add cron job to user's crontab (runs every 2 minutes)
echo "Adding cron job to delete all Docker images every 2 minutes..."

# Check if the job already exists
(crontab -l 2>/dev/null | grep -v "$CLEANUP_SCRIPT"; echo "*/2 * * * * $CLEANUP_SCRIPT >/dev/null 2>&1") | crontab -

echo "✅ Cron job added. Docker images will be deleted every 2 minutes."


