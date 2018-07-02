FROM alpine
RUN apk add --update --no-cache libintl gettext

WORKDIR /workdir

ADD envsubst-file.sh /

ENTRYPOINT ["/envsubst-file.sh"]
