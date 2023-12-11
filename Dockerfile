FROM alpine:3.19.0
# hadolint ignore=DL3018
RUN apk add --update --no-cache libintl gettext
WORKDIR /workdir
COPY envsubst-file.sh /
ENTRYPOINT ["/envsubst-file.sh"]
