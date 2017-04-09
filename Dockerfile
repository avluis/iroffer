FROM debian:jessie-slim

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
IROFFER_VER=snap \
IROFFER_TAR=iroffer.tar.gz

ENV IROFFER_URL http://iroffer.dinoex.net/iroffer-dinoex-${IROFFER_VER}.tar.gz
ENV IROFFER_SHA256 D36FF042AFE5A258A3AFB55452ADF27EB851EE8F5B8A0E488BA0D39DACF8A9A5

RUN echo "Preparing" $CONT_IMG_VER "of this container." \
 && echo "Let's begin! Adding user..." \
# add user
 && groupadd -r ${IROFFER_USER} && useradd -r -g ${IROFFER_USER} ${IROFFER_USER} \
# install required packages
 && echo "Installing essential packages..." \
 && apt-get -q update > /dev/null \
 && apt-get -qy install --no-install-recommends \
 $PREQ_PACKAGES > /dev/null 2>&1 \
# download & verify iroffer
 && echo "Downloading latest iroffer-dinoex..." \
 && curl -sSL "$IROFFER_URL" -o ${IROFFER_TAR} \
 && echo "Verifying checksum..." \
 && echo "$IROFFER_SHA256  $IROFFER_TAR" | sha256sum -c - \
# extract
 && echo "Extracting files..." \
 && tar -C /tmp -xzf ${IROFFER_TAR} \
 && rm ${IROFFER_TAR} \
 && echo "Installing build packages..." \
 && echo "This will take a while..." \
# install build packages
 && apt-get -q update > /dev/null \
 && apt-get -qy install --no-install-recommends \
 $BUILD_PACKAGES > /dev/null 2>&1 \
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
 && apt-get remove --purge -qy \
 $PREQ_PACKAGES \
 $BUILD_PACKAGES $(apt-mark showauto) > /dev/null 2>&1 \
 && apt-get autoremove -qy > /dev/null \
 && apt-get clean -qy > /dev/null \
 && cd /tmp/iroffer-dinoex-${IROFFER_VER} \
# install runtime packages
 && echo "Installing runtime packages..." \
 && apt-get -q update > /dev/null \
 && apt-get -qy install --no-install-recommends \
 $RUNTIME_PACKAGES > /dev/null 2>&1 \
 && rm -rf /var/lib/apt/lists/* \
 && ldconfig \
# organize files & modify mybot.config defaults
 && echo "Modifying iroffer default install..." \
 && bash -c 'mkdir -p $USER/{config,data,extras/www,logs} \
 && cp -p iroffer / \
 && cp *.html /extras/www \
 && cp -r htdocs /extras/www \
 && cp sample.config /extras/sample.config \
 && cd / \
 && chown -R ${IROFFER_USER}: {config,data,extras,logs} \
 && chmod 600 /extras/sample.config \
 && cp -n /extras/sample.config config/mybot.config \
 && sed -i -e "s|pidfile mybot.pid|pidfile /config/mybot.pid|g" config/mybot.config \
 && sed -i -e "s|logfile mybot.log|logfile /logs/mybot.log|g" config/mybot.config \
 && sed -i -e "s|statefile mybot.state|statefile /config/mybot.state|g" config/mybot.config \
 && sed -i -e "s|xdcclistfile mybot.txt|xdcclistfile /files/packlist.txt|g" config/mybot.config \
 && sed -i "/channel #dinoex -noannounce/s/^/#/" config/mybot.config \
 && sed -i "/# 2nd Network/,/^$/d" config/mybot.config \
 && sed -i "/# 3st Network/,/^$/d" config/mybot.config \
 && sed -i "/#no_status_log/s/#//g" config/mybot.config \
 && chmod 700 . \
 && rm -rf /tmp/* \
 && echo "Done! Thanks for waiting~"'

WORKDIR $USER/
COPY entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/entrypoint.sh /entrypoint.sh

VOLUME ["${IROFFER_CONFIG_DIR}", "${IROFFER_DATA_DIR}"]
EXPOSE 30000-31000

ENTRYPOINT ["entrypoint.sh"]