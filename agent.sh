#!/bin/bash

# Ask user for inputs
read -p "Agent name (e.g. azureagent1): " AGENT_NAME
read -p "Azure DevOps URL (e.g. https://dev.azure.com/Shubham298/): " AZDO_URL
AUTH_METHOD="PAT"  # assuming always PAT auth
read -s -p "Personal Access Token (PAT): " PAT_TOKEN
echo
read -p "Agent Pool name (e.g. azureagent): " AGENT_POOL
read -p "Work directory (e.g. /home): " WORK_DIR

# Create agent directory
mkdir -p myagent
cd myagent || exit 1

# Download and extract agent
AGENT_VERSION="4.259.0"
AGENT_FILE="vsts-agent-linux-x64-$AGENT_VERSION.tar.gz"
AGENT_URL="https://download.agent.dev.azure.com/agent/$AGENT_VERSION/$AGENT_FILE"

echo "Downloading Azure DevOps agent version $AGENT_VERSION..."
wget -q --show-progress "$AGENT_URL"

echo "Extracting agent..."
tar zxf "$AGENT_FILE"

# Configure the agent
echo "Configuring the agent..."
./config.sh --unattended \
  --agent "$AGENT_NAME" \
  --url "$AZDO_URL" \
  --auth "$AUTH_METHOD" \
  --token "$PAT_TOKEN" \
  --pool "$AGENT_POOL" \
  --work "$WORK_DIR"

# Run the agent
echo "Starting the agent..."
./run.sh

