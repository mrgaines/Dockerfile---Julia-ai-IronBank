ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/opensource/julia/julia-base
ARG BASE_TAG=latest

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

USER root
RUN dnf upgrade -y --nodocs && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN mkdir -p /tmp/ai-packages/ /ai-packages/
COPY *.tar.gz /tmp/ai-packages/
RUN for f in /tmp/ai-packages/*.tar.gz; do tar xvf $f -C /ai-packages; done
RUN rm -rf /tmp/ai-packages
chmod +x /ai-packages/

USER 1000
CMD ["JULIA_DEPOT_PATH=/ai-packages /julia/julia-1.7.2/bin/julia"]
HEALTHCHECK NONE
