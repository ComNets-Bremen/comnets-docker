#!/bin/sh
# Build the image from scratch

OMNETPP_URL="https://omnetpp.org/component/jdownloads/download/32-release-older-versions/2323-omnetpp-5-2-1-core"

if [ ! -f "omnetpp.tgz" ]; then
    echo "\"omnetpp.tgz\" not found. Please download OMNeT++ and save it into this directory."
    echo "The required version can be downloaded here: $OMNETPP_URL"
    exit
fi

docker build --no-cache . -t omnetpp-base:omnetpp-5.2.1
