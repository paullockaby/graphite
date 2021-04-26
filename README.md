# graphite
This container runs the [graphite-web](https://github.com/graphite-project/graphite-web)
daemon and that's it.

## Running on Docker

This volume expects to listen on one port and have two mounted volumes. It
needs to listen on port 8080 TCP. It needs to have `/opt/graphite/conf` and
`/opt/graphite/storage` mounted.

    docker build -t ghcr.io/paullockaby/graphite:latest .
    docker run --rm -it -p 8080:8080/tcp -v $PWD/storage:/opt/graphite/storage -v $PWD/example:/opt/graphite/conf ghcr.io/paullockaby/graphite:latest

Alternatively you can use the Makefile to do builds and run the tool all in one
step:

    make run

An example configuration file is in the `example` directory.
