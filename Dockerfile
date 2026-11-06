# Copyright IBM Corp. 2020, 2026
# SPDX-License-Identifier: BUSL-1.1

# This Dockerfile contains multiple targets.
# Use 'docker build --target=<name> .' to build one.
# e.g. `docker build --target=dev .`
#
# All non-dev targets have a VERSION argument that must be provided 
# via --build-arg=VERSION=<version> when building. 
# e.g. --build-arg=0.7.4
#
# `default` is the production docker image which cannot be built locally. 
# For local dev and testing purposes, please build and use the `dev` docker image.


# Development docker image
FROM docker.mirror.hashicorp.services/alpine:3.21 as dev

RUN set -eux && \
    addgroup boundary && \
    adduser -s /bin/sh -S -G boundary boundary && \
    apk add --no-cache wget ca-certificates dumb-init gnupg libcap openssl su-exec iputils libc6-compat iptables

ADD bin/boundary /bin/boundary

RUN mkdir /boundary/
ADD .release/docker/config.hcl /boundary/config.hcl
RUN chown -R boundary:boundary /boundary/
RUN chmod -R 640 /boundary/*

EXPOSE 9200 9201 9202
VOLUME /boundary/

LABEL org.opencontainers.image.licenses="BUSL-1.1"

COPY .release/docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY bin/LICENSE.txt /usr/share/doc/boundary/LICENSE.txt

USER boundary
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["server", "-config", "/boundary/config.hcl"]
