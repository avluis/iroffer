FROM debian:8.1
MAINTAINER Luis E Alvarado <admin@avnet.ws>

RUN apt-get update && \
    apt-get install -y \
    make \
    gcc \
    libc-dev \
    libcurl4-openssl-dev \
    libgeoip-dev \
    libssl-dev \
    ruby2.1-dev \
    ruby2.1 \
    ngircd && \
    apt-get clean

RUN sed -i 's/.*;DNS = yes.*/DNS = no/' /etc/ngircd/ngircd.conf
RUN sed -i 's/.*;Ident = yes.*/Ident = no/' /etc/ngircd/ngircd.conf

WORKDIR /opt/iroffer
ADD http://iroffer.dinoex.net/iroffer-dinoex-3.30.tar.gz /opt/iroffer-dinoex-3.30.tar.gz
COPY mybot.* /opt/iroffer/
RUN tar xfz /opt/iroffer-dinoex-3.30.tar.gz -C /opt/iroffer && rm /opt/iroffer-dinoex-3.30.tar.gz

RUN cd iroffer-dinoex-3.30 && \
    ./Configure -curl -geoip -ruby && \
    make && \
    cp -p iroffer .. && \
    cp *.html .. && \
    cp -r htdocs ../ && \
    mkdir ../files && \
    cd .. && \
    rm -r /opt/iroffer/iroffer-dinoex-3.30 && \
    useradd iroffer && chown -R iroffer:iroffer /opt/iroffer && chmod 700 /opt/iroffer

CMD ngircd && \
    sed -i "s/#usenatip .*/usenatip ${EXTERNAL_IP}/" /opt/iroffer/mybot.config && \
    ./iroffer -b -u iroffer /opt/iroffer/mybot.config && \
    tail -F /opt/iroffer/mybot.log

VOLUME /opt/iroffer/files
EXPOSE 6667 50000-50010
