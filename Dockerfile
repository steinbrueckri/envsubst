FROM alpine:3.10.3
RUN apk add --update --no-cache libintl gettext

WORKDIR /workdir

ADD envsubst-file.sh /

ENTRYPOINT ["/envsubst-file.sh"]
