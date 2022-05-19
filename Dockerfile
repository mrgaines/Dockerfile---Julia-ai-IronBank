ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/opensource/r/julia-base
ARG BASE_TAG=latest
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

ARG USER="joules"
ARG UID="1000"
ARG GID="100"

RUN dnf upgrade -y --nodocs && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN mkdir -p /tmp/ai-packages/ tmp/ai-packages/
COPY *.tar.gz /tmp/ai-packages/ 
RUN mkdir /ai-packages && \
    tar zxvf /tmp/ai-packages/*.tar.gz -C /tmp/ai-packages

USER 1001

ENV VIRTUAL_ENV=/opt/julia/venv
RUN julia -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN using Pkg --no-index --find-links /ai-packages/     \
        Pkg.add("Tensorflow")                           \
        Pkg.add("MLBase")                               \
        Pkg.add("Clustering")                           \
        Pkg.add("ScikitLearn")                          \
        Pkg.add("Flux")                                 \
        Pkg.add("Merlin")                               \
        Pkg.add("Knet")                                 \
        Pkg.add("TextAnalysis")                         \
        Pkg.add("StatsModels")                          \
        Pkg.add("DecisionTree")                         \
        Pkg.add("LIBSVM")                               \
        Pkg.add("MLJ")                                  \
        Pkg.add("MLJModels")                            \
        Pkg.add("JuliaParser")                          \
        Pkg.add("MLKernels")                            \
        Pkg.add("Kernels")                              \
        Pkg.add("ANN")                                  \
        Pkg.add("JuliaParser")                          \
        Pkg.add("OnlineAI")                             \
        Pkg.add("RDatasets")                            \
        Pkg.add("UnicodePlots")                         \
        Pkg.add("Languages")


RUN using Pkg --no-index --find-links /opt/python/repo/tmp/ai-packages/    \
        Pkg.add("FileIO")                                   \
        Pkg.add("ForwardDiff")                              \
        Pkg.add("DiffResults")                              \
        Pkg.add("Interpolations")                           \
        Pkg.add("NLopt")                                    \
        Pkg.add("OrdinaryDiffEq")                           \
        Pkg.add("Plots")                                    \
        Pkg.add("RobotOSData")

#########################
# Compliance Mitigation #
#########################

USER root

# Removing unneeded vulnerable binaries

RUN useradd -m -s /bin/bash -N -u $UID -g $GID $USER   \
    && chmod -R 775 /home/joules

USER $UID

CMD ["/julia/julia-1.7.2/bin/julia"]

HEALTHCHECK NONE

