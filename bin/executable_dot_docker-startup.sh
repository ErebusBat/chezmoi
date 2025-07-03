#!/bin/bash

# Docker Desktop startup script for macOS
# This script starts Docker Desktop and launches compose projects

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker Desktop is running
is_docker_running() {
    docker info &> /dev/null
    return $?
}

# Function to wait for Docker Desktop to be ready
wait_for_docker() {
    print_status "Waiting for Docker Desktop to be ready..."
    local max_attempts=30
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if is_docker_running; then
            print_status "Docker Desktop is ready!"
            return 0
        fi

        echo -n "."
        sleep 2
        ((attempt++))
    done

    print_error "Docker Desktop failed to start within timeout period"
    return 1
}

# Function to start Docker Desktop
start_docker_desktop() {
    if is_docker_running; then
        print_status "Docker Desktop is already running"
        return 0
    fi

    print_status "Starting Docker Desktop..."
    open -a Docker

    if ! wait_for_docker; then
        print_error "Failed to start Docker Desktop"
        exit 1
    fi
}

# Function to start a compose project
start_compose_project() {
    local project_path=$1
    local project_name=$(basename "$project_path")

    if [ ! -d "$project_path" ]; then
        print_error "Project directory does not exist: $project_path"
        return 1
    fi

    print_status "Starting compose project: $project_name"
    cd "$project_path"

    # Check if custom .dockerup file exists
    if [ -f "$project_path/.dockerup" ]; then
        print_status "Found .dockerup file, using custom startup script for $project_name"

        # Make sure the .dockerup file is executable
        chmod +x "$project_path/.dockerup"

        # Execute the custom startup script
        if ./.dockerup; then
            print_status "Successfully started $project_name using .dockerup"
        else
            print_error "Failed to start $project_name using .dockerup"
            return 1
        fi
    else
        # Standard compose startup
        if [ ! -f "$project_path/docker-compose.yml" ] && [ ! -f "$project_path/docker-compose.yaml" ] && [ ! -f "$project_path/compose.yml" ] && [ ! -f "$project_path/compose.yaml" ]; then
            print_error "No compose file found in: $project_path"
            return 1
        fi

        # Pull latest images (optional - comment out if you don't want this)
        # print_status "Pulling latest images for $project_name..."
        # docker compose pull

        # Start the project
        docker compose up -d

        if [ $? -eq 0 ]; then
            print_status "Successfully started $project_name"
        else
            print_error "Failed to start $project_name"
            return 1
        fi
    fi
}

# Main execution
main() {
    print_status "Starting Docker Desktop and compose projects..."

    # Start Docker Desktop
    start_docker_desktop

    # Define compose project paths
    declare -a projects=(
        "/Users/aburns/src/ccam/paperless"
        "/Users/aburns/src/ccam/api"
        "/Users/aburns/src/erebusbat/myserver/dashy"
    )

    # Start each compose project
    for project in "${projects[@]}"; do
        start_compose_project "$project"
        echo # Add blank line for readability
    done

    print_status "All projects started successfully!"
    print_status "Running containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Run main function
main "$@"
