# Container with an OMNeT++ installation
#
# Container with a core OMNeT++ installation. Some ideas are taken from the
# OMNeT++ tutorial: https://docs.omnetpp.org/tutorials/cloud/page2/
#
# Jens Dede <jd@comnets.uni-bremen.de>
#

FROM ubuntu:18.04
LABEL maintainer="Jens Dede <jd@comnets.uni-bremen.de>"


ENV TZ Etc/UTC
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY omnetpp.tgz /opt/
COPY README.md /opt/

RUN apt-get update -y && apt-get install -y python3-minimal python3-pip \
      build-essential bison flex libxml2-dev zlib1g-dev python-minimal wget

WORKDIR /opt/

RUN tar xf omnetpp.tgz && rm omnetpp.tgz

RUN ln -s omnetpp* omnetpp

ENV PATH /opt/omnetpp/bin:$PATH

WORKDIR omnetpp

RUN apt-get install -y tcl-dev tk-dev xvfb
#RUN apt-get install -y libopenscenegraph-dev openscenegraph-plugin-osgearth libosgearth-dev qt4-default

RUN ./configure WITH_TKENV=no WITH_QTENV=no WITH_OSG=no WITH_OSGEARTH=no

RUN make MODE=release -j $(nproc)
WORKDIR /opt/

RUN apt-get install ccache -y
ENV PATH /usr/lib/ccache:$PATH

CMD cat README.md

# entry point
