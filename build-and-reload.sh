#!/bin/bash
shopt -s expand_aliases

alias docker=podman
VERSION=0.2.0
docker build . -t gcr.io/tamarintech-sites/newghostcms:$VERSION
docker tag gcr.io/tamarintech-sites/newghostcms:$VERSION gcr.io/tamarintech-sites/newghostcms:latest
docker push gcr.io/tamarintech-sites/newghostcms:$VERSION
docker push gcr.io/tamarintech-sites/newghostcms:latest

#docker push gcr.io/tamarintech-sites/newghostcms:$VERSION && \
#  docker push gcr.io/tamarintech-sites/newghostcms:latest && \
#  kubectl rollout restart deployments/sb-ghostcms -n sb-ghostcms
