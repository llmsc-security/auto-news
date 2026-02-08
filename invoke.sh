#!/bin/bash
# Invoke script for Auto-News Docker container
# Usage: ./invoke.sh [mode] [options]

set -e

CONTAINER_NAME="auto-news"
PORT=11190
IMAGE_NAME="auto-news:latest"

# Parse arguments
MODE="${1:-start}"
shift || true

# Function to start the container
start_container() {
    echo "Starting Auto-News container on port $PORT..."

    # Check if container already exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container already exists, removing..."
        docker rm -f "$CONTAINER_NAME" || true
    fi

    # Create workspace directory
    mkdir -p workspace logs

    # Run the container
    docker run -d \
        --name "$CONTAINER_NAME" \
        -p $PORT:8080 \
        -v "$(pwd)/workspace:/opt/airflow/workspace:rw" \
        -v "$(pwd)/logs:/opt/airflow/logs:rw" \
        -v "$(pwd)/dags:/opt/airflow/dags:ro" \
        -v "$(pwd)/.env:/opt/airflow/.env:ro" \
        -e PYTHONUNBUFFERED=1 \
        -e WORKDIR=/opt/airflow \
        --restart=unless-stopped \
        "$IMAGE_NAME" \
        "$@"
}

# Function to stop the container
stop_container() {
    echo "Stopping Auto-News container..."
    docker stop "$CONTAINER_NAME" || true
    docker rm -f "$CONTAINER_NAME" || true
}

# Function to show logs
show_logs() {
    docker logs -f "$CONTAINER_NAME"
}

# Function to run command inside container
run_command() {
    docker exec -it "$CONTAINER_NAME" "$@"
}

# Main logic
case "$MODE" in
    start)
        start_container
        echo "Container started successfully!"
        echo "Access the Airflow webserver at http://localhost:$PORT"
        echo ""
        echo "Default credentials:"
        echo "  Username: admin"
        echo "  Password: admin"
        ;;
    stop)
        stop_container
        echo "Container stopped successfully!"
        ;;
    logs)
        show_logs
        ;;
    exec)
        shift
        run_command "$@"
        ;;
    scheduler)
        echo "Starting Airflow scheduler..."
        docker run -d \
            --name "${CONTAINER_NAME}-scheduler" \
            -v "$(pwd)/workspace:/opt/airflow/workspace:rw" \
            -v "$(pwd)/logs:/opt/airflow/logs:rw" \
            -v "$(pwd)/dags:/opt/airflow/dags:ro" \
            -v "$(pwd)/.env:/opt/airflow/.env:ro" \
            -e PYTHONUNBUFFERED=1 \
            "$IMAGE_NAME" \
            airflow scheduler
        ;;
    *)
        echo "Usage: $0 {start|stop|logs|exec <cmd>}"
        echo ""
        echo "Modes:"
        echo "  start    - Start the container in daemon mode"
        echo "  stop     - Stop and remove the container"
        echo "  logs     - Follow container logs"
        echo "  exec     - Execute a command inside the container"
        exit 1
        ;;
esac
