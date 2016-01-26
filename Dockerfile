FROM debian:jessie

MAINTAINER Erick Almeida <ephillipe@gmail.com>

# all the apt-gets in one command & delete the cache after installing

# Install build dependencies
RUN apt-get update \
    && apt-get install -y \
       build-essential libevent-dev ca-certificates curl \
    && apt-get -q -y clean 
    
EXPOSE 5432

RUN groupadd -r pgbouncer && useradd -r -g pgbouncer pgbouncer

ENV PGBOUNCER_VERSION 1.7
ENV PGBOUNCER_URL http://pgbouncer.github.io/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz

# Get PgBouncer source code
RUN curl -SLO ${PGBOUNCER_URL} \
  && tar -xzf pgbouncer-${PGBOUNCER_VERSION}.tar.gz \
  && chown root:root pgbouncer-${PGBOUNCER_VERSION}

# Configure, make, and install
RUN cd pgbouncer-${PGBOUNCER_VERSION} \
  && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
  && make \
  && make install

ADD pgbouncer.ini /var/app/pgbouncer/pgbouncer.ini
ADD auth_file.ini /var/app/pgbouncer/auth_file.ini

RUN chown pgbouncer:pgbouncer /var/app/pgbouncer/ -R \
 	&& chmod a+w /var/log -R \
	&& chmod a+w /var/run -R

CMD pgbouncer /var/app/pgbouncer/pgbouncer.ini    
