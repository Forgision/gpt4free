#!/bin/bash

# Set the necessary variables
GITHUB_REPO="xtekky/gpt4free"
# APP_DIR="/mnt/c/Users/sachi/vault/work-station/Docker/gpt4free/docker/app"
APP_DIR="/app"
# APP_DIR="/mnt/vault/@work-station/Docker/gpt4free/docker/app"

# Function to get the latest version from GitHub
get_latest_github_version() {
    curl --silent "https://api.github.com/repos/$GITHUB_REPO/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"([^"]+)".*/\1/'
}

# Get the current version from the environment variable
CURRENT_VERSION=$G4F_VERSION
if [ -z "$CURRENT_VERSION" ]; then
    echo "Environment variable G4F_VERSION is not set."
    exit 1
fi
echo "Current version: $CURRENT_VERSION"

while true; do

    # Get the latest version from the GitHub repository
    LATEST_VERSION=$(get_latest_github_version)
    if [ -z "$LATEST_VERSION" ]; then
        echo "Failed to get the latest version from GitHub."
        exit 1
    fi
    echo "Latest version from GitHub: $LATEST_VERSION"

    # Compare versions
    if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
        echo "New version available. Updating..."

        # Clone or pull the repository
        if [ -d "$APP_DIR/.git" ]; then
            echo "Pulling the latest version from GitHub..."
            cd "$APP_DIR" || exit
            git pull
        else
            echo "Cloning the repository from GitHub..."
            git clone https://github.com/$GITHUB_REPO.git "$APP_DIR"
        fi
        
        # Restart the processes
        supervisorctl restart g4f-gui
        supervisorctl restart g4f-api

        export G4F_VERSION=$LATEST_VERSION

        echo "Update and restart complete."
    else
        echo "You already have the latest version."
    fi

    sleep 5
done