# hadolint global ignore=DL3018
# Use the first layer to download plugins and next copy them to the final image
FROM alpine:3.23.3@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659 AS builder

COPY ./download_plugins.sh ./plugins.list ./old_plugins.list /

RUN apk add \
        bash \
        wget \
        unzip \
    && chmod +x /download_plugins.sh \
    && /download_plugins.sh

# Tiny image with only the plugins and entrypoint script
FROM alpine:3.23.3@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659

# User "nobody"
ENV USER_UID=65534

COPY --from=builder /tmp/plugins/ /etc/grafana/plugins/
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

USER ${USER_UID}

ENTRYPOINT [ "/entrypoint.sh" ]
