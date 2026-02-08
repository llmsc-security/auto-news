# Multi-stage build for Auto-News
# -------------------------------------------------
#  Builder stage – compile and install Python deps
# -------------------------------------------------
FROM python:3.12-slim-bookworm AS builder

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

# Install Python packages - copy the pyproject.toml and install
COPY pyproject.toml .
RUN pip install --default-timeout=300 --no-cache-dir .

# -------------------------------------------------
#  Runtime stage – lightweight image with app code
# -------------------------------------------------
FROM apache/airflow:2.8.4-python3.11

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /opt/airflow

ENV WORKDIR=/opt/airflow
ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# Install additional system dependencies
RUN set -ex; \
  apt-get update && apt-get install -y --no-install-recommends \
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

# Copy requirements.txt and install Python dependencies
COPY docker/requirements.txt .
RUN set -ex; \
  pip install --no-cache-dir -r requirements.txt && \
  rm -rf ~/.cache/pip

# Copy DAGs
COPY dags/ /opt/airflow/dags/

# Copy application source code
COPY --chown=airflow:airflow ./src /opt/airflow/run/auto-news/src
COPY --chown=airflow:airflow . .

# Switch to airflow user
USER airflow

# Expose any relevant ports (Airflow webserver if needed)
EXPOSE 8080

# Default command
CMD ["airflow", "webserver"]
