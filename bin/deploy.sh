#!/bin/sh
set -e

. bin/config.env

IMAGE_TAG=$(git rev-parse --short HEAD)

env_check () {
    if ! command -v "$CONTAINER_CMD" 2>&1; then
        echo "ERROR: Docker is not installed!" >&2
        return 1
    fi
}

lint_python () {
    $CONTAINER_CMD run --rm -v "$PWD":/apps alpine/flake8:latest .
}

lint_shell () {
    $CONTAINER_CMD run --rm -v "$PWD:/mnt" koalaman/shellcheck:stable ./bin/*
}

build_image () {
    ./bin/build-image.sh "$APP_NAME" "$IMAGE_TAG"
}

deploy_stack () {
    if [ "$(${CONTAINER_CMD} ps -aq -f name=^"$APP_NAME"$)" ]; then
        set_rollback
    fi
    ./bin/deploy-app.sh "$APP_NAME" "$IMAGE_TAG"
}

verify_deploy () {
    ./bin/health-check.sh check
}

set_rollback () {
    $CONTAINER_CMD stop "$APP_NAME"
    APP_ROLLBACK_CONTAINER="$APP_NAME-rollback-$(date +%s)"
    $CONTAINER_CMD rename "$APP_NAME" "$APP_ROLLBACK_CONTAINER"
    echo "INFO: Rollback flask_app '$APP_ROLLBACK_CONTAINER'"
    printf "%s" "$APP_ROLLBACK_CONTAINER" > .previous 
}

do_rollback () {
    $CONTAINER_CMD stop "$APP_NAME" || echo "INFO: $APP_NAME not running"
    APP_ROLLBACK_CONTAINER=$(cat .previous)
    $CONTAINER_CMD start "$APP_ROLLBACK_CONTAINER"
    echo "INFO: Rolled back to previous running flask_app '$APP_ROLLBACK_CONTAINER'"
}

main () {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <all|check|lint|build|deploy|verify|rollback>" >&2
        exit 1  
    fi
    cmd="$1"
    shift 
    case "$cmd" in
        check) 
            env_check
            ;;
        lint) 
            lint_python
            lint_shell
            ;;
        build) 
            build_image
            ;;
        deploy) 
            deploy_stack
            ;;
        verify) 
            verify_deploy
            ;;
        rollback)
            do_rollback
            ;;
        all)
            env_check
            lint_python
            lint_shell
            build_image
            deploy_stack
            verify_deploy
            ;;
    esac
}

main "$@"
