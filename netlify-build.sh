#!/bin/bash
set -e

# Setup Git credentials for private repos using HTTPS
if [ -n "$GITHUB_TOKEN" ]; then
  echo "Configuring Git credentials for private repositories..."
  git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
fi

# Create .env.dev file from Netlify environment variables
echo "Creating .env.dev from environment variables..."
cat > .env.dev << EOF
FLAVOR=${FLAVOR}
BASE_URL=${BASE_URL}
MAPBOX_ACCESS_TOKEN=${MAPBOX_ACCESS_TOKEN}
APP_NAME=${APP_NAME}
ENV=${ENV}
EOF

echo ".env.dev file created successfully"

# Run Flutter build
flutter build web --target lib/main_dev.dart