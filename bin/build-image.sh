#!/bin/sh

. bin/config.env

build_image () {
    $CONTAINER_CMD build --progress=plain -t "$1":"$2" .
}

main () {
    if [ $# -le 1 ]; then
        echo "Usage: $0 image_name image_tag" >&2
        exit 1  
    fi
    build_image "$1" "$2"
}

main "$@"
