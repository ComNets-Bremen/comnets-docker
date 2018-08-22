#!/bin/sh
# Build the image from scratch

OMNETPP_URL="https://omnetpp.org/omnetpp/summary/30-omnet-releases/2329-omnetpp-5-4-1-core"

if [ ! -f "omnetpp.tgz" ]; then
    echo "\"omnetpp.tgz\" not found. Please download OMNeT++ and save it into this directory."
    echo "The required version can be downloaded here: $OMNETPP_URL"
    exit
fi

docker build --no-cache . -t omnetpp-base
