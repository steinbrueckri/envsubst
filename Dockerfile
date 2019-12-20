FROM alpine:3.11.0
RUN apk add --update --no-cache libintl gettext

WORKDIR /workdir

ADD envsubst-file.sh /

ENTRYPOINT ["/envsubst-file.sh"]
