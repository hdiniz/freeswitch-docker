#!/bin/sh

set -e

./bootstrap.sh -j

for i in $(echo $ENABLED_MODULES | sed 's/,/ /g')
do
    sed -i "s;^#$i;$i;g" modules.conf
done

for i in $(echo $DISABLED_MODULES | sed 's/,/ /g')
do
    sed -i "s;^$i;#$i;g" modules.conf
done

PKG_CONFIG_PATH=/lib/pkgconfig ./configure --prefix=
mkdir -p /usr/build/prefix
make -j`nproc` && make DESTDIR=/usr/build/prefix/ install