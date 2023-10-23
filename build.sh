#!/bin/bash
shopt -s expand_aliases
alias docker=podman

GHOST_CLI_VERSION=latest
GHOST_VERSION=5.70.1

docker build . \
	--build-arg GHOST_VERSION=$GHOST_VERSION \
	--build-arg GHOST_CLI_VERSION=$GHOST_CLI_VERSION \
	-t ghostcms:$GHOST_VERSION

#podman tag ghostcms:$GHOST_VERSION ghostcms:latest
