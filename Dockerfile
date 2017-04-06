FROM debian:wheezy

ENV BUILD_ARGS="-curl -geoip -upnp -ruby"
ARG CONT_IMG_VER
ENV CONT_IMG_VER ${CONT_IMG_VER:-v0.0.1}

LABEL name="docker-iroffer" \
      version=$CONT_IMG_VER \
      maintainer="Luis E Alvarado <admin@avnet.ws>" \
      description="iroffer-dinoex mod XDCC Bot with curl, geoip, upnp & ruby support."

# TODO: $RUNTIME_PACKAGES
ENV BUILD_PACKAGES \
 ca-certificates \
 curl \
 gcc \
 libc-dev \
 libcurl4-openssl-dev \
 libgeoip-dev \
 libminiupnpc-dev \
 libssl-dev \
 make \
 ruby1.8-dev \
 ruby1.8 \
 libruby1.8

# User configurable variables.
ENV IROFFER_USER=iroffer \
 IROFFER_CONFIG_DIR=/config \
 IROFFER_CONFIG_FILE=mybot.config \
 IROFFER_DATA_DIR=/files \
 IROFFER_LOG_DIR=/logs \
 IROFFER_LOG_FILE=mybot.log \
 IROFFER_WWW_DIR=/www \
 IROFFER_VER=snap \
 DEBIAN_FRONTEND=noninteractive

  # download iroffer-dinoex
ADD http://iroffer.dinoex.net/iroffer-dinoex-${IROFFER_VER}.tar.gz \
 /tmp/iroffer-dinoex.tar.gz
RUN tar xfz /tmp/iroffer-dinoex.tar.gz -C /tmp/ \
 && rm /tmp/iroffer-dinoex.tar.gz \

# add our user and group first to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
 && groupadd -r ${IROFFER_USER} && useradd -r -g ${IROFFER_USER} ${IROFFER_USER} \
 && echo "Preparing" $CONT_IMG_VER "of this container." \
 && echo "This will take a while..." \

# install packages
 && apt-get -qq update \
 && apt-get -qqy install --no-install-recommends \
 $BUILD_PACKAGES \
 && /sbin/ldconfig \

# build iroffer-dinoex
 && cd /tmp/iroffer-dinoex-${IROFFER_VER} \
 && echo "Building " $CONT_IMG_VER " of this container." \
 && chmod a+x ./Configure \
 && ./Configure ${BUILD_ARGS} \
 && make \
 && mkdir /extras \
 && mkdir /extras/www \
 && cp -p iroffer / \
 && cp *.html /extras/www \
 && cp -r htdocs /extras/www \
 && cp sample.config /extras/sample.config \
 && cd / \
 && chown -R ${IROFFER_USER}:${IROFFER_USER} /extras \
 && chmod 600 /extras/sample.config \
	
# cleanup
 && apt-get remove --purge -y \
 $BUILD_PACKAGES $(apt-mark showauto) \
 && rm -r /tmp/iroffer-dinoex-${IROFFER_VER} \
 && chmod 700 . \
 && echo "Finally! Putting in the final touches." \

# TODO ($RUNTIME_PACKAGES)
# && apt-get -qq update \
# && apt-get -qqy install $RUNTIME_PACKAGES \
 && apt-get autoremove -y \
 && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh \
 && ln -s usr/local/bin/entrypoint.sh /entrypoint.sh

EXPOSE 8000 30000-31000

VOLUME ["${IROFFER_CONFIG_DIR}"]
VOLUME ["${IROFFER_DATA_DIR}"]

ENTRYPOINT ["entrypoint.sh"]
CMD ["-b -u" ${IROFFER_USER} ${IROFFER_CONFIG_DIR}"/"${IROFFER_CONFIG_FILE} "&>/dev/null &"]
