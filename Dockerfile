ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/opensource/julia/julia-base
ARG BASE_TAG=latest

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

USER root
RUN dnf upgrade -y --nodocs && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN mkdir -p /tmp/ai-packages/ /ai-packages/
COPY julia-ai-packages.tar.gz /tmp/ai-packages/
RUN tar xvf /tmp/ai-packages/julia-ai-packages.tar.gz -C /ai-packages
RUN rm -rf /tmp/ai-packages
RUN chmod +x /ai-packages/

RUN rm -f /ai-packages/installhere/packages/MbedTLS/4YY6E/test/clntsrvr/* \
          /ai-packages/installhere/packages/HTTP/aTjcj/test/resources/*

USER 1000
CMD ["JULIA_DEPOT_PATH=/ai-packages /julia/julia-1.7.2/bin/julia"]
HEALTHCHECK NONE
