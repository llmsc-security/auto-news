# Multi-stage build for Auto-News
# -------------------------------------------------
#  Builder stage - compile and install Python deps
# -------------------------------------------------
FROM python:3.11-slim-bookworm AS builder

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /build

# Install build-time system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        pkg-config \
        ca-certificates \
        libssl-dev \
        libffi-dev \
        ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and create virtual environment
RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m venv /opt/venv

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
ENV PIP_NO_CACHE_DIR=1

# Install Python packages - copy files needed for installation
COPY pyproject.toml README.md ./
RUN pip install --default-timeout=300 --no-cache-dir .

# -------------------------------------------------
#  Runtime stage - lightweight image with app code
# -------------------------------------------------
FROM apache/airflow:2.8.4-python3.11

ARG DEBIAN_FRONTEND=noninteractive

# Switch to root to install packages (base image switches to airflow user)
USER root

WORKDIR /opt/airflow

ENV WORKDIR=/opt/airflow
ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/opt/venv
# Put system airflow path first, then venv for custom dependencies
ENV PATH="/usr/local/bin:${VIRTUAL_ENV}/bin:${PATH}"
ENV PIP_USER=false

# Install additional system dependencies (run as root explicitly)
RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    g++ \
    curl \
    wget \
    git \
    libgomp1 \
    ffmpeg \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /root/.cache/*

# Create directories and set permissions
RUN set -ex; \
  mkdir -p /opt/airflow/run/auto-news/src && \
  chmod -R 777 /opt/airflow/run/auto-news/src

# Copy the pre-built virtual environment from the builder
COPY --from=builder /opt/venv /opt/venv

# Copy requirements.txt from docker folder and install
COPY docker/requirements.txt /opt/airflow/requirements.txt
RUN set -ex; \
    /opt/venv/bin/pip install --upgrade pip --isolated; \
    /opt/venv/bin/pip install --no-cache-dir --default-timeout=300 -r /opt/airflow/requirements.txt; \
    rm -rf ~/.cache/pip

# Copy DAGs
COPY dags/ /opt/airflow/dags/

# Copy application source code
COPY --chown=airflow:airflow ./src /opt/airflow/run/auto-news/src
COPY --chown=airflow:airflow . .

# Copy the entrypoint script that initializes the database
COPY entry_point.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to airflow user
USER airflow

# Expose any relevant ports (Airflow webserver if needed)
EXPOSE 8080

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
