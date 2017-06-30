FROM docker-registry.emergya.com:443/emergya/ubuntu:16.04

# initial install of av daemon
RUN echo "deb http://es.archive.ubuntu.com/ubuntu/ xenial multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -qq \
        clamav-daemon \
        clamav-freshclam \
        libclamunrar7 \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# initial update of av databases
RUN wget -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd && \
    wget -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd && \
    wget -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
    chown clamav:clamav /var/lib/clamav/*.cvd

# permission juggling
RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

# volume provision
VOLUME ["/var/lib/clamav"]

# port provision
EXPOSE 3310

# av daemon bootstrapping
ADD  assets/etc/clamav/clamd.conf /etc/clamav/clamd.conf
ADD  assets/etc/clamav/freshclam.conf /etc/freshclam.conf
ADD  assets/bin /assets/bin

CMD ["/assets/bin/entrypoint.sh"]
