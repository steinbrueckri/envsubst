FROM alpine:3.11.2
RUN apk add --update --no-cache libintl=0.19.8.1-r4 gettext=0.19.8.1-r4
WORKDIR /workdir
COPY envsubst-file.sh /
ENTRYPOINT ["/envsubst-file.sh"]
