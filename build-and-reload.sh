#!/bin/bash
shopt -s expand_aliases

alias docker=podman
GHOST_VERSION=4.47.1

docker build . \
	--build-arg GHOST_VERSION=$GHOST_VERSION \
	--build-arg GHOST_CLI_VERSION=$GHOST_CLI_VERSION \
	-t gcr.io/tamarintech-sites/ghostcms:$GHOST_VERSION

docker tag gcr.io/tamarintech-sites/ghostcms:$GHOST_VERSION gcr.io/tamarintech-sites/ghostcms:latest
docker push gcr.io/tamarintech-sites/ghostcms:$GHOST_VERSION
docker push gcr.io/tamarintech-sites/ghostcms:latest
