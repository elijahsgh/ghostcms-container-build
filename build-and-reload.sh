#!/bin/bash
shopt -s expand_aliases

alias docker=podman
GHOST_VERSION=5.64.0
GHOST_CLI_VERSION=latest

docker build . \
	--build-arg GHOST_VERSION=$GHOST_VERSION \
	--build-arg GHOST_CLI_VERSION=$GHOST_CLI_VERSION \
	-t gcr.io/tamarintech-sites/ghostcms:$GHOST_VERSION \
	--no-cache

#docker tag gcr.io/tamarintech-sites/ghostcms:$GHOST_VERSION gcr.io/tamarintech-sites/ghostcms:latest
docker push gcr.io/tamarintech-sites/ghostcms:$GHOST_VERSION
#docker push gcr.io/tamarintech-sites/ghostcms:latest
