ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/opensource/r/julia-base
ARG BASE_TAG=latest
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

USER root

RUN dnf upgrade -y --nodocs && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN mkdir -p /tmp/ai-packages/ /ai-packages/
COPY *.tar.gz /tmp/ai-packages/
RUN tar zxvf /tmp/ai-packages/*.tar.gz -C /ai-packages

USER 1001

ENV VIRTUAL_ENV=/opt/julia/venv
RUN julia -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN using Pkg --no-index --find-links /opt/python/repo/tmp/ai-packages/    \
        Pkg.add("Mocha")                                \
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
RUN rpm -e --nodeps   \
    binutils          \
    glibc-devel       \
    glibc-headers     \
    kernel-headers

# Modifying identified SUID files
RUN chmod g-s /usr/libexec/openssh/ssh-keysign

##########################
# Clean up install files #
##########################

RUN rm -rf /opt/python/repo

USER 1001

WORKDIR $HOME

HEALTHCHECK --interval=10s --timeout=1s CMD -c 'print("up")' || exit 1

