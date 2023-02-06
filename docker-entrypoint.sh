#!/bin/sh

trap 'freeswitch -stop' SIGTERM
freeswitch -nc -nf -nonat >& /dev/null &
pid="$!"

echo "Running freeswitch... see fs_cli or /var/log/freeswitch/freeswitch.log"
wait $pid
exit 0