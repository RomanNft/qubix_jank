#!/bin/bash

# Ensure the script exits on any command failure
set -e

# Navigate to the correct directory
cd "$(dirname "$0")"

# Check if .NET SDK is installed
if ! command -v dotnet &> /dev/null
then
    echo ".NET SDK could not be found, installing..."
    # Add .NET installation steps here
    # Example:
    # wget -q https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
    # chmod +x dotnet-install.sh
    # ./dotnet-install.sh --channel 6.0
fi

# Check if wait-for-postgres.sh exists
if [ ! -f "wait-for-postgres.sh" ]; then
    echo "wait-for-postgres.sh not found in the current directory"
    exit 1
fi

# Ensure the required scripts have execute permissions
chmod +x wait-for-postgres.sh

# Build and run the Docker containers
docker-compose up --build -d

# Additional setup steps can be added here
