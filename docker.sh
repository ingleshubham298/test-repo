#!/bin/bash

MIN_DISK_SPACE=2048  # MB

# Show OS info
OS_NAME=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
OS_VERSION=$(grep '^VERSION=' /etc/os-release | cut -d= -f2 | tr -d '"')
echo "Operating System: $OS_NAME $OS_VERSION"


# Check disk space on root
AVAILABLE_SPACE=$(df / --output=avail | tail -1)
AVAILABLE_SPACE_MB=$((AVAILABLE_SPACE / 1024))
echo "Available disk space on / : ${AVAILABLE_SPACE_MB}MB"

if [ "$AVAILABLE_SPACE_MB" -lt "$MIN_DISK_SPACE" ]; then
  echo "Not enough disk space. Need at least ${MIN_DISK_SPACE}MB."
  exit 1
fi

# Check Docker
if command -v docker &> /dev/null; then
  CURRENT_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
  echo "Docker is installed, version: $CURRENT_VERSION"

  read -p "Do you want to upgrade Docker to the latest version? (y/n): " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    DO_UPGRADE=true
  else
    DO_UPGRADE=false
  fi
else
  echo "Docker is not installed."
  DO_UPGRADE=true
fi

if [ "$DO_UPGRADE" = true ]; then
  # Install prerequisites
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

  # Add Docker’s official GPG key if not already added
  if ! apt-key list | grep -q "Docker"; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  fi

  # Add Docker repo if not already added
  if ! grep -q "download.docker.com" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  fi

  sudo apt-get update
  echo "Installing/upgrading Docker..."
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  echo "Docker installation/upgrade complete."
else
  echo "Skipping Docker upgrade."
fi

