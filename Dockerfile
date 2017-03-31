FROM debian:jessie

MAINTAINER Luis E Alvarado <admin@avnet.ws>

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r iroffer && useradd -r -g iroffer iroffer

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

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
 && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
 && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true

# download iroffer-dinoex
RUN curl -o \
 /tmp/iroffer-dinoex.tar.gz -L \
	"http://iroffer.dinoex.net/iroffer-dinoex-3.30.tar.gz" && \
 tar xf \
 /tmp/iroffer-dinoex.tar.gz -C \
	/ && \

# build iroffer-dinoex
 cd iroffer-dinoex-3.30 && \
 ./Configure -curl -geoip -ruby && \
 make && \
 mkdir /config && \
 mkdir /www && \
 cp -p iroffer .. && \
 cp *.html ../www && \
 cp -r htdocs ../www && \
 cp sample.config ../config/sample.config && \
 cd .. && \
 chmod 600 /config/sample.config && \
	
# cleanup
 apt-get clean && \
 rm -r /iroffer-dinoex-3.30

RUN chown -R iroffer:iroffer /config && chmod 700 .
VOLUME /config
VOLUME /files

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh && ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8000 30000-31000
CMD [ "iroffer" ]
