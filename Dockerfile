FROM debian:jessie

MAINTAINER Luis E Alvarado <admin@avnet.ws>

ENV IROFFER_USER=iroffer \
 IROFFER_CONFIG_DIR=/config \
 IROFFER_CONFIG_FILE=mybot.config \
 IROFFER_DATA_DIR=/files \
 IROFFER_LOG_DIR=/logs \
 IROFFER_LOG_FILE=mybot.log \
 IROFFER_WWW_DIR=/www \
 IROFFER_VER=3.30 \
 DEBIAN_FRONTEND=noninteractive

# add our user and group first to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
RUN groupadd -r ${IROFFER_USER} && useradd -r -g ${IROFFER_USER} ${IROFFER_USER}

# install packages
RUN apt-get update && apt-get install -y --no-install-recommends \
 ca-certificates \
 make \
 gcc \
 libc-dev \
 libcurl4-openssl-dev \
 libgeoip-dev \
 libssl-dev \
 ruby-dev \
 ruby \
 libruby \
 curl \
 wget \
 && rm -rf /var/lib/apt/lists/*

# download iroffer-dinoex
RUN curl -o \
 /tmp/iroffer-dinoex.tar.gz -L \
	"http://iroffer.dinoex.net/iroffer-dinoex-${IROFFER_VER}.tar.gz" && \
 tar xf \
 /tmp/iroffer-dinoex.tar.gz -C \
	/ && \

# build iroffer-dinoex
 cd iroffer-dinoex-${IROFFER_VER} && \
 ./Configure -curl -geoip -ruby && \
 make && \
 mkdir ${IROFFER_CONFIG_DIR} && \
 mkdir ${IROFFER_WWW_DIR} && \
 cp -p iroffer .. && \
 cp *.html ..${IROFFER_WWW_DIR} && \
 cp -r htdocs ..${IROFFER_WWW_DIR} && \
 cp sample.config ..${IROFFER_CONFIG_DIR}/sample.config && \
 cd .. && \
 chmod 600 ${IROFFER_CONFIG_DIR}/sample.config && \
	
# cleanup
 apt-get clean && \
 rm -r /iroffer-dinoex-${IROFFER_VER}

RUN chown -R ${IROFFER_USER}:${IROFFER_USER} ${IROFFER_CONFIG_DIR} && chmod 700 .

COPY entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh && ln -s usr/local/bin/entrypoint.sh /entrypoint.sh

EXPOSE 8000 30000-31000
VOLUME ["${IROFFER_CONFIG_DIR}"]
VOLUME ["${IROFFER_DATA_DIR}"]
ENTRYPOINT ["entrypoint.sh"]
