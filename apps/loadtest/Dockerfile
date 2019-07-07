FROM golang as build-env
RUN go get -u github.com/rakyll/hey

FROM debian:stretch-slim

WORKDIR /app
COPY --from=build-env /go/bin/hey /app
COPY loadtest.sh /app

# fixing for permission denied issues

RUN  chmod +x /app/loadtest.sh

ENTRYPOINT ["/app/loadtest.sh"]