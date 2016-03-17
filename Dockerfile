FROM debian:jessie
MAINTAINER Erick Almeida <ephillipe@gmail.com>

ENV BUILD_PACKAGES="build-essential automake autoconf libtool autotools-dev pkg-config libevent-dev ca-certificates curl git libc-ares-dev libssl-dev unzip"
ENV RUNTIME_PACKAGES="openssl"

# all the apt-gets in one command & delete the cache after installing
# Install build dependencies
RUN apt-get update && \
	apt-get upgrade -y && \
    apt-get install -y $BUILD_PACKAGES $RUNTIME_PACKAGES && \
    apt-get clean -y && \
	apt-get autoclean -y && \
	apt-get autoremove -y && \
	rm -rf /usr/share/locale/* && \
	rm -rf /var/cache/debconf/*-old && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /usr/share/doc/*
    
EXPOSE 5432

RUN groupadd -r pgbouncer && useradd -r -g pgbouncer pgbouncer

RUN cd /tmp && \
    git clone https://github.com/ephillipe/pgbouncer.git && \
	cd pgbouncer && \
	git submodule init && \
	git submodule update && \
	./autogen.sh && \
	./configure --prefix=/usr/local --with-cares --with-openssl && \
	make && \
	make install && \
	rm -f -R /tmp/pgbouncer

ADD pgbouncer.ini /var/app/pgbouncer/pgbouncer.ini
ADD auth_file.ini /var/app/pgbouncer/auth_file.ini

RUN chown pgbouncer:pgbouncer /var/app/pgbouncer/ -R \
 	&& chmod a+w /var/log -R \
	&& chmod a+w /var/run -R

CMD pgbouncer /var/app/pgbouncer/pgbouncer.ini
