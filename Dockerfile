FROM debian:wheezy

LABEL name="docker-iroffer" \
      version=$CONT_IMG_VER \
      maintainer="Luis E Alvarado <admin@avnet.ws>" \
      description="iroffer-dinoex mod XDCC Bot with curl, geoip, upnp & ruby support."

ENV BUILD_ARGS="-curl -geoip -upnp -ruby"
ARG CONT_IMG_VER
ENV CONT_IMG_VER ${CONT_IMG_VER:-v0.0.1}
ARG DEBIAN_FRONTEND=noninteractive

ENV BUILD_PACKAGES \
      ca-certificates \
      gcc \
      libc-dev \
      libssl-dev \
      make \
      ruby1.8-dev \
      ruby1.8

ENV RUNTIME_PACKAGES \
      libcurl4-openssl-dev \
      libgeoip-dev \
      libminiupnpc-dev \
      libruby1.8

# User configurable variables.
ENV IROFFER_USER=iroffer \
      IROFFER_CONFIG_DIR=/config \
      IROFFER_DATA_DIR=/files \
      IROFFER_LOG_DIR=/logs \
      IROFFER_LOG_FILE=mybot.log \
      IROFFER_WWW_DIR=/www \
      IROFFER_VER=snap \
      IROFFER_TAR=iroffer.tar.gz

ENV IROFFER_URL http://iroffer.dinoex.net/iroffer-dinoex-${IROFFER_VER}.tar.gz
ENV IROFFER_SHA256 D36FF042AFE5A258A3AFB55452ADF27EB851EE8F5B8A0E488BA0D39DACF8A9A5

# download iroffer-dinoex
RUN echo "Preparing" $CONT_IMG_VER "of this container." \
      && echo "Let's begin! Preparing essential packages..." \
      && apt-get -qq update > /dev/null \
      && apt-get -qq -y install --no-install-recommends curl \
      > /dev/null 2>&1 \
      && curl -sSL "$IROFFER_URL" -o ${IROFFER_TAR} \
      && echo "$IROFFER_SHA256  $IROFFER_TAR" | sha256sum -c - \
      && tar -C /tmp -xzf ${IROFFER_TAR} \
      && rm ${IROFFER_TAR} \

# add our user and group first to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
      && groupadd -r ${IROFFER_USER} && useradd -r -g ${IROFFER_USER} ${IROFFER_USER} \
      && echo "Done! Preparing build packages..." \
      && echo "This will take a while..." \

# install packages
      && apt-get -qq update > /dev/null \
      && apt-get -qqy install --no-install-recommends \
      $BUILD_PACKAGES \
      $RUNTIME_PACKAGES > /dev/null 2>&1 \

# build iroffer-dinoex
      && echo "Done!" \
      && cd /tmp/iroffer-dinoex-${IROFFER_VER} \
      && echo "Configuring build...." \
      && chmod a+x ./Configure \
      && ./Configure ${BUILD_ARGS} > /dev/null 2>&1 \
      && echo "Making build...." \
      && make > /dev/null 2>&1 \
      && echo "Build complete! Moving files..." \
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
      && echo "Cleaning up -- not much long now..." \
      && apt-get remove --purge -qqy curl \
      $BUILD_PACKAGES $(apt-mark showauto) > /dev/null 2>&1 \
      && rm -r /tmp/iroffer-dinoex-${IROFFER_VER} \
      && chmod 700 . \
      && echo "Almost there... Time for the final touches..." \
      && apt-get -qq update > /dev/null \
      && apt-get -qqy install --no-install-recommends \
      $RUNTIME_PACKAGES > /dev/null 2>&1 \
      && apt-get autoremove -qqy > /dev/null \
      && apt-get clean -qqy > /dev/null \
      && rm -rf /var/lib/apt/lists/* \
      && echo "Done! Thanks for waiting~"

COPY entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh \
      && ln -s usr/local/bin/entrypoint.sh /entrypoint.sh

EXPOSE 8000 30000-31000

VOLUME ["${IROFFER_CONFIG_DIR}", "${IROFFER_DATA_DIR}"]

ENTRYPOINT ["entrypoint.sh"]