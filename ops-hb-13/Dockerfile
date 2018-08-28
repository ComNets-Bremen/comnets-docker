# Container with an OPS (Opportunistic Protocol Simulator) installation
#
# Jens Dede <jd@comnets.uni-bremen.de>
#

FROM comnets/omnetpp-base:omnetpp-5.2.1
LABEL maintainer="Jens Dede <jd@comnets.uni-bremen.de>"

COPY README.md /opt/

WORKDIR /opt/

RUN apt-get update

# Required by OPS
RUN apt-get install -y git autoconf automake libtool

# Required by INET
RUN apt-get install -y openscenegraph-plugin-osgearth libosgearth-dev qt4-default libopenscenegraph-dev

RUN git clone -b Submission-HB13 https://github.com/ComNets-Bremen/OPS.git
WORKDIR OPS

# Build OPS
RUN ./bootstrap.sh
RUN ./ops-makefile-setup.sh
RUN make -j $(nproc)

# The output directory for the simulation results
RUN mkdir -p simulations/out

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt

CMD ["bash"]
#CMD cat README.md
