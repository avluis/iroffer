FROM lsiobase/xenial
MAINTAINER Luis E Alvarado <admin@avnet.ws>

# set environment variables
ENV DEBIAN_FRONTEND="noninteractive" \
IROFFER_FILES_DIR="/config/files" \
IROFFER_USER=abc

# install packages
RUN \
 apt-get update && \
 apt-get install -y \
 make \
 gcc \
 libc-dev \
 libcurl4-openssl-dev \
 libgeoip-dev \
 libssl-dev \
 ruby \
 libruby \
 wget && \

# install iroffer-dinoex
 curl -o \
 /tmp/iroffer-dinoex.tar.gz -L \
	"http://iroffer.dinoex.net/iroffer-dinoex-3.30.tar.gz" && \
 tar xf \
 /tmp/iroffer-dinoex.tar.gz -C \
	/ && \

# build iroffer-dinoex
 cd iroffer-dinoex-3.30 && \
 ./Configure -curl -geoip -ruby && \
 make && \
 cp -p iroffer .. && \
 cp *.html .. && \
 cp -r htdocs ../ && \
 cp sample.config ../sample.config && \
 cd .. && \
 chmod 600 /sample.config && \
	
 usermod -d /app abc && \
	
# cleanup
 apt-get clean && \
 rm -r /iroffer-dinoex-3.30

# add local files
COPY root/ /

CMD ./iroffer -b -u abc /config/mybot.config

EXPOSE 8000 30000-31000
VOLUME /config
