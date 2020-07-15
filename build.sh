#!/bin/bash

export BUILDKIT_INLINE_CACHE=1 DOCKER_BUILDKIT=1 SHA=$(git rev-parse HEAD) TAG=master DOCKER_IMAGE=gaganpreetarora/buildkit-test

# Start with a clean slate
sudo docker system prune -af

# Build first image, tag with master and push to registry
docker build backend --progress=plain -t $DOCKER_IMAGE:$SHA --cache-from $DOCKER_IMAGE:$TAG --build-arg BUILDKIT_INLINE_CACHE=1 --build-arg INSTALL_DEV=true
docker tag $DOCKER_IMAGE:$SHA $DOCKER_IMAGE:$TAG 
docker push $DOCKER_IMAGE:$TAG
docker run $DOCKER_IMAGE:$SHA python test.py

# Clean everything again
sudo docker system prune -af

# Build second image, this time a cache exists in the registry
docker build backend --progress=plain -t $DOCKER_IMAGE:$SHA-missing-files --cache-from $DOCKER_IMAGE:$TAG --build-arg BUILDKIT_INLINE_CACHE=1 --build-arg INSTALL_DEV=true
docker run $DOCKER_IMAGE:$SHA-missing-files python test.py
docker push $DOCKER_IMAGE:$SHA-missing-files
