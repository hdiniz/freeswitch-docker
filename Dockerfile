FROM debian:11 as build

RUN apt-get update
# Adapted https://github.com/signalwire/freeswitch/blob/v1.10.9/docker/examples/Debian11/Dockerfile#L12
RUN apt-get -yq install \
    git wget \
# build
    build-essential cmake automake autoconf 'libtool-bin|libtool' pkg-config \
# general
    libssl-dev zlib1g-dev libdb-dev unixodbc-dev libncurses5-dev libexpat1-dev libgdbm-dev bison erlang-dev libtpl-dev libtiff5-dev uuid-dev \
# core
    libpcre3-dev libedit-dev libsqlite3-dev libcurl4-openssl-dev nasm \
# core codecs
    libogg-dev libspeex-dev libspeexdsp-dev \
# mod_enum
    libldns-dev \
# mod_python3
    python3-dev \
# mod_av
    libavformat-dev libswscale-dev libavresample-dev \
# mod_lua
    liblua5.2-dev \
# mod_opus
    libopus-dev \
# mod_pgsql
    libpq-dev \
# mod_sndfile
    libsndfile1-dev libflac-dev libogg-dev libvorbis-dev \
# mod_conference
    libpng-dev libfreetype6-dev \
# mod_shout
    libshout3-dev libmpg123-dev libmp3lame-dev

ARG SOFIA_SIP_REPO=https://github.com/freeswitch/sofia-sip
ARG SOFIA_SIP_REVISION=v1.13.12
RUN mkdir -p /usr/src/libs/sofia-sip && \
    cd /usr/src/libs/sofia-sip && \
    git init && \
    git remote add origin ${SOFIA_SIP_REPO} && \
    git fetch --depth 1 origin ${SOFIA_SIP_REVISION} && \
    git reset --hard FETCH_HEAD

ARG SPANDSP_REPO=https://github.com/freeswitch/spandsp
ARG SPANDSP_REVISION=master
RUN mkdir -p /usr/src/libs/spandsp && \
    cd /usr/src/libs/spandsp && \
    git init && \
    git remote add origin ${SPANDSP_REPO} && \
    git fetch --depth 1 origin ${SPANDSP_REVISION} && \
    git reset --hard FETCH_HEAD

ARG FREESWITCH_REPO=https://github.com/signalwire/freeswitch
ARG FREESWITCH_REVISION=v1.10.9
RUN mkdir -p /usr/src/freeswitch && \
    cd /usr/src/freeswitch && \
    git init && \
    git remote add origin ${FREESWITCH_REPO} && \
    git fetch --depth 1 origin ${FREESWITCH_REVISION} && \
    git reset --hard FETCH_HEAD


RUN cd /usr/src/libs/sofia-sip && \
    ./bootstrap.sh && \
    ./configure --with-pic --with-glib=no --without-doxygen --prefix= && \
    make -j`nproc --all` && \
    make install

RUN cd /usr/src/libs/spandsp && \
    ./bootstrap.sh && \
    ./configure --with-pic --prefix= && \
    make -j`nproc --all` && \
    make install

WORKDIR /usr/src/freeswitch
ADD build-freeswitch.sh .
ARG ENABLED_MODULES=
ARG DISABLED_MODULES=endpoints/mod_verto,applications/mod_signalwire
RUN ENABLED_MODULES=${ENABLED_MODULES} DISABLED_MODULES=${DISABLED_MODULES} ./build-freeswitch.sh
ADD create-min-root.sh .
RUN ./create-min-root.sh

FROM build as assets
RUN wget https://files.freeswitch.org/releases/sounds/freeswitch-sounds-en-us-callie-8000-1.0.53.tar.gz
RUN wget https://files.freeswitch.org/releases/sounds/freeswitch-sounds-music-8000-1.0.8.tar.gz

FROM busybox:glibc
COPY --from=assets /usr/src/freeswitch/freeswitch-sounds-en-us-callie-8000-1.0.53.tar.gz .
RUN mkdir -p /share/freeswitch/sounds && \
    tar xzvf freeswitch-sounds-en-us-callie-8000-1.0.53.tar.gz -C /share/freeswitch/sounds && \
    rm freeswitch-sounds-en-us-callie-8000-1.0.53.tar.gz
COPY --from=assets /usr/src/freeswitch/freeswitch-sounds-music-8000-1.0.8.tar.gz .
RUN mkdir -p /share/freeswitch/sounds && \
    tar xzvf freeswitch-sounds-music-8000-1.0.8.tar.gz -C /share/freeswitch/sounds && \
    rm freeswitch-sounds-music-8000-1.0.8.tar.gz

COPY --from=build /root/min-root.tar.gz .
RUN tar xzvf min-root.tar.gz && rm min-root.tar.gz
ADD docker-entrypoint.sh .
CMD ["/docker-entrypoint.sh"]
