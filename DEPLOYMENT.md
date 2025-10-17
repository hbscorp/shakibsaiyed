# Deployment Guide

This document outlines prerequisites, setup, troubleshooting, and rollback procedures for the stack.

## Prerequisites

- OS: Ubuntu 20.04+ or similar Linux
- Network: Internet access to pull images
- Docker (or Podman) 20.10+
- POSIX shell (Bash/sh)
- Git

## Deploy

Recommended entrypoint runs lint, build, deploy, and checks:

```bash
bin/deploy.sh all
```

Or run individual steps:

```bash
bin/deploy.sh check | lint | build | deploy | verify | rollback
```

## Rollback

`bin/deploy.sh rollback` stops the current app container and starts the previously saved container name stored in `.previous`.

## Troubleshooting

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| bind: address already in use | App port already used | Change `APP_PORT` in `bin/config.env` and retry |

