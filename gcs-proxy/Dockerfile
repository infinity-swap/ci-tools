FROM golang:1.18-alpine3.16 as build

RUN apk add --update ca-certificates
RUN apk add --no-cache --virtual .build-deps ca-certificates make

WORKDIR /build

COPY ./gcsproxy/* /build/

RUN go mod download
RUN make bin/gcsproxy 

FROM alpine:3.16  

COPY --from=build /build/bin/gcsproxy /usr/local/bin/

RUN chmod +x /usr/local/bin/gcsproxy

RUN ls -l /usr/local/bin/

CMD gcsproxy -v -b :8080
