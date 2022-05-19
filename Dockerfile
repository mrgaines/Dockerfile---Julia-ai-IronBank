ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/opensource/r/julia-base
ARG BASE_TAG=latest
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

USER root

RUN dnf upgrade -y      && \
    dnf clean all -y    && \
    dnf install -y         \
        zip                \
        unzip              \
        net-tools          \
        curl               \
        git                \
        gcc-c++

RUN mkdir -p /opt/julia/repo /tmp/ai-packages
RUN chown -R 1001:users /opt/julia


# pipeline
#COPY *.tar.gz /tmp/ai-packages
#RUN tar xfz /tmp/ai-packages/python38-ai-packages-04-21-2022.tar.gz -C /opt/python/repo
#RUN tar xfz /tmp/ai-packages/python-ai-packages-03-31-2022.tar.gz -C /opt/python/repo

USER 1001

ENV VIRTUAL_ENV=/opt/julia/venv
RUN julia -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN using Pkg --no-index --find-links /opt/python/repo/tmp/python38-ai-package-downloads/    \
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


RUN using Pkg --no-index --find-links /opt/python/repo/tmp/python38-ai-package-downloads/    \
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

# Removing identified secret
RUN rm -rf /usr/share/doc/perl-IO-Socket-SSL/certs/                 && \
    rm -rf /usr/share/doc/perl-IO-Socket-SSL/example/               && \
    rm -rf /usr/share/doc/perl-IO-Socket-SSL/example/               && \
    rm -rf /usr/share/doc/perl-Net-SSLeay/examples/server_key.pem   && \
    rm -rf /opt/python/venv/lib/python3.8/site-packages/future/backports/test/badkey.pem && \
    rm -rf /opt/python/venv/lib/python3.8/site-packages/future/backports/test/badcert.pem && \
    rm -rf /opt/python/venv/lib/python3.8/site-packages/dulwich/contrib/test_paramiko_vendor.py && \
    rm -rf /opt/python/venv/lib/python3.8/site-packages/future/backports/test/keycert.pem && \
    rm -rf /opt/python/venv/lib/python3.8/site-packages/future/backports/test/ssl_key.pem && \
    rm -rf /opt/python/venv/lib/python3.8/site-packages/future/backports/test/ssl_key.passwd.pem && \
    rm -rf /opt/python/venv/lib/python3.8/site-packages/future/backports/test/keycert.passwd.pem && \
    rm -rf /opt/python/venv/lib/python3.8/site-packages/future/backports/test/keycert2.pem

# Mitigation for Docker package for python
RUN rm -rf /opt/python/venv/lib/python3.8/site-packages/docker-5.0.3.dist-info/*
RUN rm -rf /opt/python/venv/lib/python3.8/site-packages/docker/*


# Modifying identified SUID files
RUN chmod g-s /usr/libexec/openssh/ssh-keysign

##########################
# Clean up install files #
##########################

RUN rm -rf /opt/python/repo

USER 1001

WORKDIR $HOME

HEALTHCHECK --interval=10s --timeout=1s CMD python3.8 -c 'print("up")' || exit 1

