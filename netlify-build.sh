#!/bin/bash
set -e

# Setup SSH for private submodules
if [ -n "$GIT_SSH_KEY" ]; then
  echo "Setting up SSH key for private repositories..."
  mkdir -p ~/.ssh
  echo "$GIT_SSH_KEY" > ~/.ssh/id_ed25519
  chmod 600 ~/.ssh/id_ed25519
  ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null

  # Configure git to use SSH instead of HTTPS for this repo
  git config --global url."git@github.com:".insteadOf "https://github.com/"
fi

# Run Flutter build
flutter build web --target lib/main_dev.dart