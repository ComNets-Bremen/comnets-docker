#!/bin/sh

# Push the images to hub.docker.io

docker tag omnetpp-base:omnetpp-5.2.1 comnets/omnetpp-base:omnetpp-5.2.1
docker push comnets/omnetpp-base:omnetpp-5.2.1

