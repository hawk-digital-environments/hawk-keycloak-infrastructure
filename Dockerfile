# This version is a placeholder and does not reflect the actual version used in the project.
ARG KEYCLOAK_VERSION=26.1
FROM alpine:latest AS builder
RUN apk add curl
RUN mkdir -p /opt/downloads
RUN curl -L -o /opt/downloads/hawk-auth-server-extension.jar \
    https://github.com/HAWK-Digital-Environments/hawk-keycloak-auth-server/releases/latest/download/hawk-auth-server-extension.jar

# This version is a placeholder and does not reflect the actual version used in the project.
ARG KEYCLOAK_VERSION=26.1
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS local_ext_dev
COPY --from=extension --chown=keycloak:keycloak hawk-auth-server-extension.jar /opt/keycloak/providers/hawk-auth-server-extension.jar
RUN /opt/keycloak/bin/kc.sh build

ARG KEYCLOAK_VERSION
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
COPY --from=builder --chown=keycloak:keycloak /opt/downloads/hawk-auth-server-extension.jar /opt/keycloak/providers/hawk-auth-server-extension.jar
RUN /opt/keycloak/bin/kc.sh build
