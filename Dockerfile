FROM alpine:3.10.1
RUN apk add --update --no-cache libintl gettext

WORKDIR /workdir

ADD envsubst-file.sh /

ENTRYPOINT ["/envsubst-file.sh"]
