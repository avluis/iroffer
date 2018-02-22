FROM debian:9-slim

LABEL name="iroffer" \
version=$CONT_IMG_VER \
maintainer="Luis E Alvarado <admin@avnet.ws>" \
description="iroffer-dinoex mod XDCC Bot with cUrl, GeoIP, Ruby & UPnP support in a container~"

ENV BUILD_ARGS="-curl -geoip -upnp -ruby"
ARG CONT_IMG_VER
ENV CONT_IMG_VER ${CONT_IMG_VER:-v1.0}
ARG DEBIAN_FRONTEND=noninteractive

ENV PREQ_PACKAGES \
curl

ENV BUILD_PACKAGES \
ca-certificates \
gcc \
libc-dev \
libcurl4-openssl-dev \
libgeoip-dev \
libminiupnpc-dev \
libssl-dev \
make \
ruby \
ruby-dev

ENV RUNTIME_PACKAGES \
libcurl3 \
libgeoip1 \
libminiupnpc10 \
ruby

# User configurable variables.
ENV IROFFER_USER=iroffer \
IROFFER_CONFIG_DIR=/config \
IROFFER_DATA_DIR=/files \
IROFFER_LOG_DIR=/logs \
IROFFER_TAR=iroffer.tar.gz

ARG IROFFER_USER_ID=999
ARG IROFFER_GROUP_ID=999

ARG IROFFER_VER=snap
ARG IROFFER_SHA256=FFCEDD67B124C2B2BB9B9FD1883D38112076E1412BC1625590C58B95B396E0A9

ENV IROFFER_URL http://iroffer.dinoex.net/iroffer-dinoex-${IROFFER_VER}.tar.gz

ENV IROFFER_CONFIG_FILE_NAME=mybot.config

RUN echo "Preparing" $CONT_IMG_VER "of this container." \

# add user
 && echo "Let's begin! Adding user..." \
 && groupadd -g ${IROFFER_GROUP_ID} -r ${IROFFER_USER} && useradd -u ${IROFFER_USER_ID} -r -g ${IROFFER_USER} ${IROFFER_USER} \

# install required packages
 && echo "Installing essential packages..." \
 && apt-get -q update > /dev/null \
 && apt-get -qy install --no-install-recommends $PREQ_PACKAGES > /dev/null 2>&1 \

# download & verify iroffer
 && echo "Downloading latest iroffer-dinoex..." \
 && curl -sSL "$IROFFER_URL" -o ${IROFFER_TAR} \
 && echo "Verifying checksum..." \
 && echo "$IROFFER_SHA256  $IROFFER_TAR" | sha256sum -c - \

# extract
 && echo "Extracting files..." \
 && tar -C /tmp -xzf ${IROFFER_TAR} \
 && rm ${IROFFER_TAR} \

# install build packages
 && echo "Installing build packages..." \
 && echo "This will take a while..." \
 && apt-get -q update > /dev/null \
 && apt-get -qy install --no-install-recommends $BUILD_PACKAGES > /dev/null 2>&1 \

# build iroffer-dinoex
 && cd /tmp/iroffer-dinoex-${IROFFER_VER} \
 && echo "Configuring build..." \
 && chmod a+x ./Configure \
 && ./Configure ${BUILD_ARGS} > /dev/null 2>&1 \
 && echo "Making build..." \
 && make > /dev/null 2>&1 \
 && echo "Build complete!" \

# clean up
 && echo "Cleaning up..." \
 && apt-get remove --purge -qy $PREQ_PACKAGES $BUILD_PACKAGES > /dev/null 2>&1 \
 && apt-get autoremove -qy > /dev/null \
 && apt-get clean -qy > /dev/null \

# install runtime packages
 && echo "Installing runtime packages..." \
 && apt-get -q update > /dev/null \
 && apt-get -qy install --no-install-recommends $RUNTIME_PACKAGES > /dev/null 2>&1 \
 && rm -rf /var/lib/apt/lists/* \
 && ldconfig \

# organize files & modify config defaults
 && echo "Modifying iroffer default install..." \
 && bash -c 'mkdir -p $USER/{config,data,extras/www,logs}' \
 && cd /tmp/iroffer-dinoex-${IROFFER_VER} \
 && cp -p iroffer / \
 && cp *.html /extras/www \
 && cp -r htdocs /extras/www \
 && cp sample.config /extras/sample.config \
 && chmod 600 /extras/sample.config \
 && cp -n /extras/sample.config /extras/sample.customized.config \
 && bash -c 'chown -R ${IROFFER_USER}: /{config,data,extras,logs}' \
 && sed -i -e "s|pidfile mybot.pid|pidfile /config/mybot.pid|g" /extras/sample.customized.config \
 && sed -i -e "s|logfile mybot.log|logfile /logs/mybot.log|g" /extras/sample.customized.config \
 && sed -i -e "s|statefile mybot.state|statefile /config/mybot.state|g" /extras/sample.customized.config \
 && sed -i -e "s|xdcclistfile mybot.txt|xdcclistfile /files/packlist.txt|g" /extras/sample.customized.config \
 && sed -i "/channel #dinoex -noannounce/s/^/#/" /extras/sample.customized.config \
 && sed -i "/# 2nd Network/,/^$/d" /extras/sample.customized.config \
 && sed -i "/# 3st Network/,/^$/d" /extras/sample.customized.config \
 && sed -i "/#no_status_log/s/#//g" /extras/sample.customized.config \
 && chmod 700 . \
 && rm -rf /tmp/* \
 && echo "Done! Thanks for waiting~"

WORKDIR $USER/
COPY entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh \
 && ln -s usr/local/bin/entrypoint.sh /entrypoint.sh

VOLUME ["${IROFFER_CONFIG_DIR}", "${IROFFER_DATA_DIR}"]
EXPOSE 30000-31000

ENTRYPOINT ["entrypoint.sh"]