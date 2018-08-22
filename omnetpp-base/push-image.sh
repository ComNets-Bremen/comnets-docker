#!/bin/sh

# Push the images to hub.docker.io

docker tag omnetpp-base comnets/omnetpp-base
docker push comnets/omnetpp-base
