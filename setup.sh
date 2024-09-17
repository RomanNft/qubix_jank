#!/bin/bash

# Ensure the script exits on any command failure
set -e

# Install .NET SDK if not already installed
if ! command -v dotnet &> /dev/null
then
    echo ".NET SDK could not be found, installing..."
    # Add .NET installation steps here
    # Example:
    # wget -q https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
    # chmod +x dotnet-install.sh
    # ./dotnet-install.sh --channel 6.0
fi

# Navigate to the correct directory
cd "$(dirname "$0")"

# Ensure the required scripts have execute permissions
chmod +x wait-for-postgres.sh

# Build and run the Docker containers
docker-compose up --build -d

# Additional setup steps can be added here
