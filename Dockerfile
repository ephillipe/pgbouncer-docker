FROM debian:jessie

MAINTAINER Erick Almeida <ephillipe@gmail.com>

# all the apt-gets in one command & delete the cache after installing

RUN apt-get update \
    && apt-get install -y ca-certificates \
       build-essential make libpcre3-dev libssl-dev wget \
       iputils-arping libexpat1-dev unzip curl libncurses5-dev libreadline-dev \
       perl htop \
    && apt-get -q -y clean 
    
EXPOSE 5432

RUN groupadd -r pgbouncer && useradd -r -g pgbouncer pgbouncer

ENV PGBOUNCER_VERSION 1.5.4
ENV PGBOUNCER_URL https://apt.postgresql.org/pub/projects/pgFoundry/pgbouncer/pgbouncer/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz

# Install build dependencies
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends build-essential libevent-dev ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*

# Get PgBouncer source code
RUN curl -SLO ${PGBOUNCER_URL} \
  && tar -xzf pgbouncer-${PGBOUNCER_VERSION}.tar.gz \
  && chown root:root pgbouncer-${PGBOUNCER_VERSION}

# Configure, make, and install
RUN cd pgbouncer-${PGBOUNCER_VERSION} \
  && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
  && make \
  && make install

ADD pgbouncer.ini pgbouncer.ini

CMD pgbouncer pgbouncer.ini    
