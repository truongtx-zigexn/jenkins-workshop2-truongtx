#!/bin/bash

# Deploy to local container (remote-host) following workshop1 structure
# Uses Jenkins pipeline parameters and follows the same deployment pattern

# Container connection details (for local deployment to remote-host container)
CONTAINER_HOST="remote_host"
SSH_USER="remote_user"
SSH_KEY="/var/jenkins_home/ansible/remote-key"

# Use Jenkins pipeline parameters (with defaults for local testing)
TARGET_BASE="${TARGET_BASE:-/usr/share/nginx/html/jenkins}"
YOUR_NAME="${YOUR_NAME:-truongtx}"
RETAIN_RELEASES="${RETAIN_RELEASES:-5}"

echo "🐳 Deploying to local container: $CONTAINER_HOST"
echo "   Target: $TARGET_BASE/$YOUR_NAME"

# Step 1: Copy web-performance-project1-initial to personal folder (like template copy in workshop1)
echo "📦 Step 1: Copying source files to personal folder..."
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$SSH_USER@$CONTAINER_HOST" bash -lc "
    mkdir -p '$TARGET_BASE/$YOUR_NAME'
    # Copy the web project files to personal folder
    if [ -d '$TARGET_BASE/$YOUR_NAME/web-performance-project1-initial' ]; then
        rm -rf '$TARGET_BASE/$YOUR_NAME/web-performance-project1-initial'
    fi
    mkdir -p '$TARGET_BASE/$YOUR_NAME/web-performance-project1-initial'
"

# Copy files from Jenkins workspace to container
echo "📤 Copying files from workspace to container..."
cd web-performance-project1-initial
scp -o StrictHostKeyChecking=no -i "$SSH_KEY" -r \
    index.html 404.html css js images \
    "$SSH_USER@$CONTAINER_HOST:$TARGET_BASE/$YOUR_NAME/web-performance-project1-initial/"
cd ..

# Step 2: Check nginx status
echo "🔍 Step 2: Checking nginx status..."
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$SSH_USER@$CONTAINER_HOST" \
    "service nginx status || systemctl status nginx || true"

# Step 3: Create release directory
echo "📁 Step 3: Creating release directory..."
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$SSH_USER@$CONTAINER_HOST" bash -lc "
    set -euxo pipefail
    RELEASE_DATE=\$(date -u +%Y%m%d_%H%M)
    mkdir -p '$TARGET_BASE/$YOUR_NAME/deploy/'\$RELEASE_DATE
    echo \"RELEASE_DATE=\$RELEASE_DATE\" > '$TARGET_BASE/$YOUR_NAME/deploy/.last_release'
"

# Step 4: Deploy files to release directory
echo "🚀 Step 4: Deploying files to release directory..."
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$SSH_USER@$CONTAINER_HOST" bash -lc "
    set -euxo pipefail
    RELEASE_DATE=\$(cat '$TARGET_BASE/$YOUR_NAME/deploy/.last_release' | cut -d= -f2)
    # Copy all web files to release directory
    cp -r '$TARGET_BASE/$YOUR_NAME/web-performance-project1-initial/'* \
          '$TARGET_BASE/$YOUR_NAME/deploy/'\$RELEASE_DATE'/'
"

# Step 5: Update current symlink
echo "🔗 Step 5: Updating current symlink..."
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$SSH_USER@$CONTAINER_HOST" bash -lc "
    set -euxo pipefail
    RELEASE_DATE=\$(cat '$TARGET_BASE/$YOUR_NAME/deploy/.last_release' | cut -d= -f2)
    ln -sfn '$TARGET_BASE/$YOUR_NAME/deploy/'\$RELEASE_DATE \
            '$TARGET_BASE/$YOUR_NAME/deploy/current'
"

# Step 6: Prune old releases
echo "🧹 Step 6: Cleaning up old releases..."
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$SSH_USER@$CONTAINER_HOST" bash -lc "
    set -euxo pipefail
    cd '$TARGET_BASE/$YOUR_NAME/deploy'
    ls -1dt -- * | grep -v '^current\$' | awk \"NR>$RETAIN_RELEASES\" | xargs -r -I{} rm -rf -- {}
"

echo "✅ Local deployment completed successfully!"
echo "   Container: $CONTAINER_HOST"
echo "   Path: $TARGET_BASE/$YOUR_NAME/deploy/current"
echo "   Files deployed: index.html, 404.html, css/, js/, images/"
echo "=================================================="
