#!/bin/sh

# Scripts config (prefer bin/config.env as source of truth)
export  APP_NAME="s3_data_service" \
        IMAGE_TAG="latest" \
        CONTAINER_CMD="docker" \
        RETRIES_MAX=1 \
        RETRIES_TIMEOUT=5

# Minio config
export  MINIO_CONSOLE_ADDRESS=":8080" \
        MINIO_ROOT_USER="root" \
        MINIO_ROOT_PASSWORD="73gQJipov1RVPXzDRbmP" \
        MINIO_VOLUMES="/mnt/minio/data" \
        MINIO_OPTS=""
