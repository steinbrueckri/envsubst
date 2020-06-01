FROM alpine:3.12.0
RUN apk add --update --no-cache libintl=0.20.1-r2 gettext=0.20.1-r2
WORKDIR /workdir
COPY envsubst-file.sh /
ENTRYPOINT ["/envsubst-file.sh"]
