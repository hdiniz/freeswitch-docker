# freeswitch-docker

This Dockerfile compiles Freeswitch from source along sofia-sip and spandsp.

Different sources can be specified as docker build args.

To run Freeswitch on a container, use the host network and mount your configuration directory to `/etc/freeswitch`:

```sh
docker run --net host \
    -v /etc/freeswitch:/etc/freeswitch \
    -v /usr/share/fonts/truetype/freefont/FreeMono.ttf:/usr/share/fonts/truetype/freefont/FreeMono.ttf \
    freeswitch
```



## Build Arguments

e.g. 

```sh
docker build -f Dockerfile \
    --build-arg FREESWITCH_REPO=https://github.com/hdiniz/freeswitch \
    --build-arg FREESWITCH_REVISION=fix-vmute-personal-canvas \
    -t freeswitch:vmute-conf-fix .
```

- FREESWITCH_REPO
- FREESWITCH_REVISION

- SOFIA_SIP_REPO
- SOFIA_SIP_REVISION

- SPANDSP_REPO
- SPANDSP_REVISION
