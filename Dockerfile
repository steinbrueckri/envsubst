FROM alpine:3.24.1
# hadolint ignore=DL3018
RUN apk add --update --no-cache libintl gettext
WORKDIR /workdir
COPY envsubst-file.sh /
ENTRYPOINT ["/envsubst-file.sh"]
