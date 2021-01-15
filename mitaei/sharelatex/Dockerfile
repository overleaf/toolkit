FROM sharelatex/sharelatex

RUN apt -y update \
; apt-get -y --no-install-recommends install \
apt-utils \
iputils-ping \
lsof \
net-tools \
; apt-get clean && rm -rf /var/lib/apt/lists/*

#RUN mv /etc/my_init.d/98_check_db_access.sh /tmp # for testing with docker, rather than docker-compose

# textlive update & install packages
COPY packages.tl /tmp
RUN tlmgr update --self \
; tlmgr update --all \
; for tlpkg in $(cat /tmp/packages.tl); do tlmgr install $tlpkg; done
