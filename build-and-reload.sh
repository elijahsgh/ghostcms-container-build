#!/bin/bash
shopt -s expand_aliases

alias docker=podman
GHOST_VERSION=4.47.1
export GHOST_VERSION
docker build . -t gcr.io/tamarintech-sites/ghostcms:$GHOST_VERSION
docker tag gcr.io/tamarintech-sites/ghostcms:$GHOST_VERSION gcr.io/tamarintech-sites/ghostcms:latest
docker push gcr.io/tamarintech-sites/ghostcms:$GHOST_VERSION
docker push gcr.io/tamarintech-sites/ghostcms:latest

#docker push gcr.io/tamarintech-sites/newghostcms:$VERSION && \
#  docker push gcr.io/tamarintech-sites/newghostcms:latest && \
#  kubectl rollout restart deployments/sb-ghostcms -n sb-ghostcms
