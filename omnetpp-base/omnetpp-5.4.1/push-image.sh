#!/bin/sh

# Push the images to hub.docker.io

docker tag omnetpp-base comnets/omnetpp-base:omnetpp-5.4.1
docker push comnets/omnetpp-base:omnetpp-5.4.1

docker tag omnetpp-base comnets/omnetpp-base
docker push comnets/omnetpp-base

