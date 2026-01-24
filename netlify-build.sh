#!/bin/bash
set -e

# Setup Git credentials for private repos using HTTPS
if [ -n "$GITHUB_TOKEN" ]; then
  echo "Configuring Git credentials for private repositories..."
  git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
fi

# Create dotenv.dev file from Netlify environment variables
# Note: Using 'dotenv.dev' instead of '.env.dev' because files starting with 
# a dot are not properly served in Flutter web builds
echo "Creating dotenv.dev from environment variables..."
cat > dotenv.dev << EOF
FLAVOR=${FLAVOR}
BASE_URL=${BASE_URL}
MAPBOX_ACCESS_TOKEN=${MAPBOX_ACCESS_TOKEN}
APP_NAME=${APP_NAME}
ENV=${ENV}
EOF

# Verify dotenv.dev file was created and has content
if [ ! -f "dotenv.dev" ]; then
  echo "ERROR: dotenv.dev file was not created!"
  exit 1
fi

if [ ! -s "dotenv.dev" ]; then
  echo "ERROR: dotenv.dev file is empty!"
  exit 1
fi

echo "dotenv.dev file created successfully"
echo "Contents of dotenv.dev:"
cat dotenv.dev

# Run Flutter build
flutter build web --target lib/main_dev.dart