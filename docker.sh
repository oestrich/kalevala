#/bin/bash

set -ex

export DOCKER_BUILDKIT=1
sha=$(git rev-parse HEAD)

docker build -t grapevinehaus/kantele:${sha} .
docker push grapevinehaus/kantele:${sha}
