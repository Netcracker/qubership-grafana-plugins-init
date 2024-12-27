FROM alpine:3.20.3 as builder

COPY ./download_plugins.sh ./plugins.list /

RUN apk add \
        bash \
        wget \
        unzip \
    && chmod +x /download_plugins.sh \
    && /download_plugins.sh

FROM alpine:3.20.3

ENV USER_UID=65534

COPY --from=builder /tmp/plugins/ /etc/grafana/plugins/
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

USER ${USER_UID}

ENTRYPOINT [ "/entrypoint.sh" ]
