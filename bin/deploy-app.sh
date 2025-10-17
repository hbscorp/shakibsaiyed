#!/bin/sh
set -e

. bin/config.env
. bin/build-image.sh
. bin/health-check.sh

ensure_bridge_network () {
    if $CONTAINER_CMD network ls --format '{{.Name}}' | grep -q "^$1$"; then
        echo "WARNING: Network '$1' already exists"
        return 0
    fi
    $CONTAINER_CMD network create \
        --driver bridge \
        "$1"
}

start_container () {
    _start_name="$1" _start_image="$2" _start_network="$3" _start_cmd="${4:-}"
    shift 3
    if [ "$(${CONTAINER_CMD} ps -aq -f name=^"$_start_name"$)" ]; then
        echo "WARNING: Container '$_start_name' already exists."
    
        if [ "$(${CONTAINER_CMD} ps -q -f name=^"$_start_name"$)" ]; then
            echo "WARNING: Container '$_start_name' is already running."
        else
            echo "INFO: Starting existing container '$_start_name'..."
            $CONTAINER_CMD start "$_start_name"
        fi
    else
        $CONTAINER_CMD run -d \
            --name "$_start_name" \
            --network "$_start_network" \
            "$@" \
            "$_start_image" \
            ${_start_cmd:+"$_start_cmd"}
    fi

    _start_wait_count=0
    until is_service_healthy "$_start_name"; do
        if [ $_start_wait_count -ge "$RETRIES_MAX" ]; then
            echo "ERROR: Waited $((RETRIES_TIMEOUT*_start_wait_count))s for '$_start_name' to be healthy..." >&2
            return 1            
        fi
        echo "INFO: Waiting for '$_start_name' service to be healthy..."
        _start_wait_count=$((_start_wait_count+1))
        sleep "$RETRIES_TIMEOUT"
    done
}

main () {
    if [ $# -le 1 ]; then
        echo "Usage: $0 app_name app_version" >&2
        exit 1  
    fi
    build_image "$1" "$2"
    ensure_bridge_network "$1"

    start_container minio minio/minio "$1" server \
        --volume "minio-volume:$MINIO_VOLUMES" \
        -e "MINIO_VOLUMES=$MINIO_VOLUMES" \
        --health-cmd "curl -f http://localhost:9000/minio/health/live || exit 1" || exit 1

    start_container "$1" "$1:$2" "$1"  \
        -p "$APP_PORT":5000 || exit 1

    echo "Services running..."
}


main "$@"
