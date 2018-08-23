#!/bin/sh

# Push the images to hub.docker.io

docker tag ops-hb-13 comnets/ops-hb-13
docker push comnets/ops-hb-13
