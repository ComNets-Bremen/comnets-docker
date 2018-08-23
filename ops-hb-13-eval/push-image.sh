#!/bin/sh

# Push the images to hub.docker.io

docker tag ops-hb-13-eval comnets/ops-hb-13-eval
docker push comnets/ops-hb-13-eval
