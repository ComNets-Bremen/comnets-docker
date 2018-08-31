# Container to run OPS simulations. It also contains a simple user interface to
# select the simulation to run.
#
# Jens Dede <jd@comnets.uni-bremen.de>
#

FROM comnets/ops-hb-13
LABEL maintainer="Jens Dede <jd@comnets.uni-bremen.de>"

COPY README.md /opt/
COPY INFO.txt /opt/

WORKDIR /opt/

RUN apt-get update -y
RUN apt-get install -y whiptail python-numpy python-matplotlib python-scipy time vim joe nano

COPY simMenu.sh /opt/
RUN chmod +x simMenu.sh

#RUN git clone https://github.com/ComNets-Bremen/Keetchi-Evaluations/

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt

CMD ./simMenu.sh
