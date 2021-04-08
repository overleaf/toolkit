FROM golang:alpine AS build
RUN apk add git
RUN go get github.com/jsha/minica

FROM nginx:alpine

VOLUME /certs

COPY --from=build /go/bin/minica /usr/bin/minica
ADD run.sh /run.sh
ADD nginx.conf /etc/nginx/nginx.conf

EXPOSE 18443

CMD /run.sh
