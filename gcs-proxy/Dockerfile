FROM golang:1.18-alpine3.16 as build

RUN apk add --update ca-certificates
RUN apk add --no-cache --virtual .build-deps ca-certificates make

WORKDIR /build

COPY ./gcsproxy/* /build/

RUN go mod download
RUN make bin/gcsproxy 

FROM alpine:3.16  
# ENV GCSPROXY_VERSION=0.3.0
# RUN apk add --update ca-certificates
# RUN apk add --no-cache --virtual .build-deps ca-certificates wget \
#   && wget https://github.com/daichirata/gcsproxy/releases/download/v${GCSPROXY_VERSION}/gcsproxy_${GCSPROXY_VERSION}_amd64_linux -O /usr/local/bin/gcsproxy \
#   && chmod +x /usr/local/bin/gcsproxy \
#   && apk del .build-deps

# EXPOSE 8080

# COPY --from=build ./bin/gcsproxy /usr/local/bin/gcsproxy

COPY --from=build /build/bin/gcsproxy /usr/local/bin/

RUN chmod +x /usr/local/bin/gcsproxy

RUN ls -l /usr/local/bin/

CMD gcsproxy -v -b :8080