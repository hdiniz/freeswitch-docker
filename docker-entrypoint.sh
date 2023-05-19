#!/bin/sh

touch /var/log/freeswitch/freeswitch.log
trap 'freeswitch -stop' SIGTERM
freeswitch -nc -nf -nonat >& /dev/null &
pid="$!"

tail -f -n +0 /var/log/freeswitch/freeswitch.log &
tailpid=$!

wait $pid
kill $tailpid
exit 0