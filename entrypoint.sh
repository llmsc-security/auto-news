#!/bin/bash
set -e

# Function: print log message
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function: install runtime dependencies
install_runtime_dependencies() {
    log "Checking and installing runtime dependencies..."

    local requirements_file="docker/requirements.txt"
    local installed_packages_file="/tmp/installed_packages.txt"

    if [ -f "$requirements_file" ]; then
        if [ ! -f "$installed_packages_file" ] || [ "$requirements_file" -nt "$installed_packages_file" ]; then
            log "New dependencies found, installing..."
            pip install --no-cache-dir -r "$requirements_file" 2>&1 | while read line; do
                log "pip: $line"
            done
            touch "$installed_packages_file"
            log "Dependencies installed"
        else
            log "Dependencies are up to date, skipping"
        fi
    else
        log "No requirements.txt found"
    fi
}

# Function: check requirements
check_requirements() {
    log "Checking application environment..."

    # Check for required directories
    if [ ! -d "/opt/airflow/run/auto-news/src" ]; then
        log "Creating auto-news directories..."
        mkdir -p /opt/airflow/run/auto-news/src
    fi

    # Check for config files
    if [ -f ".env.template" ] && [ ! -f ".env" ]; then
        log "Copying environment template..."
        cp .env.template .env
    fi

    log "Environment check completed"
}

# Function: start the application
start_app() {
    log "Starting Auto-News Airflow..."

    # Default command is airflow webserver
    local cmd="${AUTO_NEWS_CMD:-airflow}"
    local args="${AUTO_NEWS_ARGS:-webserver}"

    log "Executing: $cmd $args"
    exec $cmd $args
}

# Main logic
log "Auto-News Docker container starting..."

# Check environment
check_requirements

# Execute based on arguments
case "$1" in
    "webserver"|"")
        start_app
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
