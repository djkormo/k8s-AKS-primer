Dummy application which display hostname and version
====================================================

> GoLang webserver which purpose is to reply with the hostname and if existing,
the environment variable VERSION.

## Getting started

### Development

Install dependencies using [dep](https://github.com/golang/dep):

```console
 dep ensure
 go run main.go
```

### Docker

#### Build

```console
$ docker build -t djkormo/k8s-dep-strat .
```

#### Run

```console
 docker run -d \
    --name app \
    -p 8080:8080 \
    -h host-1 \
    -e VERSION=v1.0.0 \
    djkormo/k8s-dep-strat
```

#### Test

```console
 curl localhost:8080
2018-01-28T00:22:04+01:00 - Host: host-1, Version: v1.0.0
```

Liveness and readiness probes are replying on `:8086/live` and `:8086/ready`.

Prometheus metrics are served at `:9101/metrics`.

#### Cleanup

```console
 docker stop app
```
