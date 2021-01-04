#/bin/bash

set -ex

export DOCKER_BUILDKIT=1
sha=$(git rev-parse HEAD)

docker build -f Dockerfile.site -t oestrich/kalevala.dev:${sha} .
docker push oestrich/kalevala.dev:${sha}

cd helm
helm upgrade kalevala static/ --namespace static-sites -f values.yml --set image.tag=${sha}
