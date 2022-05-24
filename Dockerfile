ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/opensource/julia/julia-base
ARG BASE_TAG=latest
#FROM registry1.dso.mil/ironbank/opensource/julia/julia-base as base
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

ARG USER="joules"
ARG UID="1000"
ARG GID="100"

RUN dnf upgrade -y --nodocs && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN mkdir -p /tmp/julia/ /julia/
COPY julia-1.7.2-linux-x86_64.tar.gz /tmp/julia/
RUN tar xvf /tmp/julia/julia-1.7.2-linux-x86_64.tar.gz -C /julia

RUN mkdir -p /tmp/ai-packages/ 
WORKDIR /tmp/ai-packages
COPY *.tar.gz /tmp/ai-packages/
#RUN tar xvf /tmp/ai-packages/
RUN for f in /tmp/ai-packages/*.tar.gz; do tar xvf $f -C /tmp/ai-packages; done

USER 1001

ENV VIRTUAL_ENV=/julia/venv
RUN /julia/julia-1.7.2/bin/julia
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
USER root 

RUN useradd -m -s /bin/bash -N -u $UID -g $GID $USER   \
    && chmod -R 775 /home/joules

USER $UID
CMD ["/julia/julia-1.7.2/bin/julia"]

RUN '/julia/julia-1.7.2/bin/julia' -e 'import Pkg' --no-index --find-links /tmp/ai-packages &&\
        'using Pkg; Pkg.add("Tensorflow")'                           \
        'using Pkg; Pkg.add("Clustering")'                           \
        'using Pkg; Pkg.add("ScikitLearn")'                          \
        'using Pkg; Pkg.add("Flux")'                                 \
        'using Pkg; Pkg.add("Knet")'                                 \
        'using Pkg; Pkg.add("TextAnalysis")'                         \
        'using Pkg; Pkg.add("LIBSVM")'                               \
        'using Pkg; Pkg.add("MLDatasets")'                           \
        'using Pkg; Pkg.add("JuliaParser")'                          \
        'using Pkg; Pkg.add("MLKernels")'                            \
        'using Pkg; Pkg.add("Kernels")'                              \
        'using Pkg; Pkg.add("JuliaParser")'                          \
        'using Pkg; Pkg.add("FileIO")'                               \
        'using Pkg; Pkg.add("DiffResults")'                          \
        'using Pkg; Pkg.add("Interpolations")'                       \
        'using Pkg; Pkg.add("NLopt")'                                                                  

HEALTHCHECK NONE
