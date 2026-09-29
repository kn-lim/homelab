# syntax=docker/dockerfile:1

FROM debian:13.7-slim@sha256:a99cfc517144bc59b1978475ec53b46ecabec7e43635402ee5b77cc54cd1b20a

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl git zip \
    && rm -rf /var/lib/apt/lists/*

# renovate: datasource=github-releases depName=jdx/mise
ARG MISE_VERSION=2026.9.14

RUN curl -fsSL https://mise.run | MISE_VERSION="${MISE_VERSION}" MISE_INSTALL_PATH=/usr/local/bin/mise sh

ENV MISE_SHIMS_DIR=/usr/local/share/mise/shims \
    MISE_TRUSTED_CONFIG_PATHS=/workdir/src
ENV PATH="${MISE_SHIMS_DIR}:${PATH}"

# Keep only [tools]: the [env] section holds local kubeconfig paths.
# A bind mount keeps .mise.toml out of the image layers.
RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN \
    --mount=type=bind,source=.mise.toml,target=/tmp/mise.toml \
    mkdir -p /etc/mise \
    && awk '/^\[/ { keep = ($0 == "[tools]") } keep' /tmp/mise.toml > /etc/mise/config.toml \
    && mise install --system \
    && rm -rf "$(mise cache path)"
