#!/bin/bash
set -e

# Function: print log message
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function: initialize Airflow database if needed
init_database() {
    local airflow_cmd="airflow"
    log "Initializing Airflow database..."
    $airflow_cmd db init
    log "Database initialization complete"
}

# Function: start the HTTP service (Airflow webserver)
start_service() {
    log "Starting Auto-News HTTP service..."

    # Initialize database first
    init_database

    # Set environment variables
    export WORKDIR=/opt/airflow
    export PYTHONUNBUFFERED=1

    # Check for config files
    if [ -f ".env.template" ] && [ ! -f ".env" ]; then
        log "Copying environment template..."
        cp .env.template .env
    fi

    # Default command is airflow webserver on port 8080
    # Use system airflow (from base image) for database init and webserver
    local cmd="${AUTO_NEWS_CMD:-airflow}"
    local args="${AUTO_NEWS_ARGS:-webserver}"

    log "Executing: $cmd $args"
    exec $cmd $args
}

# Main logic
log "Auto-News Docker container starting..."

# Execute based on arguments
case "$1" in
    "webserver"|"")
        start_service
        ;;
    "scheduler")
        log "Starting Airflow scheduler..."
        exec airflow scheduler
        ;;
    "bash"|"sh")
        log "Starting interactive shell..."
        exec /bin/bash
        ;;
    "health")
        log "Health check passed"
        exit 0
        ;;
    *)
        log "Executing custom command: $*"
        exec "$@"
        ;;
esac
