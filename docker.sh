#/bin/bash

set -ex

DOCKER_BUILDKIT=1 docker build -t grapevinehaus/sampo:latest .
