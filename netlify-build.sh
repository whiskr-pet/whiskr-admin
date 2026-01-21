#!/bin/bash
set -e

# Setup Git credentials for private repos using HTTPS
if [ -n "$GITHUB_TOKEN" ]; then
  echo "Configuring Git credentials for private repositories..."
  git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
fi

# Run Flutter build
flutter build web --target lib/main_dev.dart