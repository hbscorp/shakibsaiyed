#!/bin/sh
set -e

. bin/config.env

is_service_running () {
    if [ "$($CONTAINER_CMD ps -q -f name=^"$1"$)" ]; then
        return 0        
    fi
    return 1
}

is_service_healthy () {
    if [ "$($CONTAINER_CMD inspect -f '{{.State.Health.Status}}' "$1" 2>/dev/null)" = "healthy" ]; then
        return 0
    fi
    return 1
}

check_service () {
    if is_service_running "$1"; then
        echo "INFO: $1 is running..."
    else
        echo "ERROR: $1 is not running...." >&2
        exit 1
    fi

    if is_service_healthy "$1"; then
        echo "INFO: $1 is healthy..."
    else
        echo "ERROR: $1 is not healthy...." >&2
        exit 1
    fi
}

check_storage_connected () {
    response=$(curl -sf "http://localhost:$APP_PORT/storage/health" || true)
    if [ -z "$response" ]; then
        echo "ERROR: No response from storage/health" >&2
        exit 1
    fi
    status=$(echo "$response" | grep -o '"status":"[^"]*' | cut -d'"' -f4)
    storage=$(echo "$response" | grep -o '"storage":"[^"]*' | cut -d'"' -f4)
    if [ "$status" = "healthy" ] && [ "$storage" = "connected" ]; then
        echo "INFO: Storage: '$storage', status: '$status'"
        return 0
    fi
    echo "ERROR: Storage: '$storage', status: '$status'" >&2
    exit 1
}

test_upload () {
    base_url="http://localhost:$APP_PORT"
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d '{"test": "data"}' \
        "$base_url/data")
    http_code=$(echo "$response" | tail -n1)
    if [ ! "$http_code" = "201" ]; then
        echo "ERROR: Data upload failed" >&2
        echo "$response" >&2
        exit 1
    fi
    body=$(echo "$response" | sed '$d')

    filename=$(echo "$body" | grep -o '"filename":"[^"]*"' | cut -d'"' -f4)

    response=$(curl -s -w "\n%{http_code}" "$base_url/data/$filename")
    http_code=$(echo "$response" | tail -n1)
    if [ ! "$http_code" = "200" ]; then
        echo "ERROR: File not found" >&2
        echo "$response" >&2
        exit 1
    fi
    echo "INFO: Test file upload success"
}

main () {
    check_service minio
    check_service "$APP_NAME"
    check_storage_connected
    test_upload
}

if [ $# -eq 1 ]; then
    main "$@"
fi
