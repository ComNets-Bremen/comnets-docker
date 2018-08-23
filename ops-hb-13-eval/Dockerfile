# Container to run OPS simulations. It also contains a simple user interface to
# select the simulation to run.
#
# Jens Dede <jd@comnets.uni-bremen.de>
#

FROM comnets/ops-hb-13
LABEL maintainer="Jens Dede <jd@comnets.uni-bremen.de>"

COPY README.md /opt/

WORKDIR /opt/

RUN apt-get update -y
RUN apt-get install whiptail -y

COPY simMenu.sh /opt/
RUN chmod +x simMenu.sh

CMD ./simMenu.sh
