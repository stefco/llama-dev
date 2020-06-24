#------------------------------------------------------------------------------
# CREATE /etc/docker-meta.yml
ARG DOCKER_TAG
ARG NAME
ARG VERSION
ARG COMMIT
ARG URL
ARG BRANCH
ARG DATE
ARG REPO
ARG DOCKERFILE_PATH
FROM alpine AS meta
ARG DOCKER_TAG
ARG NAME
ARG VERSION
ARG COMMIT
ARG URL
ARG BRANCH
ARG DATE
ARG REPO
ARG DOCKERFILE_PATH
COPY "${DOCKERFILE_PATH}" /provision/"${DOCKERFILE_PATH}"
RUN echo >>/etc/docker-meta.yml "- name: ${NAME}" \
    && echo >>/etc/docker-meta.yml "  version: ${VERSION}" \
    && echo >>/etc/docker-meta.yml "  commit: ${COMMIT}" \
    && echo >>/etc/docker-meta.yml "  url: ${URL}" \
    && echo >>/etc/docker-meta.yml "  branch: ${BRANCH}" \
    && echo >>/etc/docker-meta.yml "  date: ${DATE}" \
    && echo >>/etc/docker-meta.yml "  repo: ${REPO}" \
    && echo >>/etc/docker-meta.yml "  docker_tag: ${DOCKER_TAG}" \
    && echo >>/etc/docker-meta.yml "  dockerfile_path: ${DOCKERFILE_PATH}" \
    && echo >>/etc/docker-meta.yml "  dockerfile: |" \
    && sed >>/etc/docker-meta.yml 's/^/    /' </provision/"${DOCKERFILE_PATH}" \
    && rm -r /provision
# END CREATE /etc/docker-meta.yml
#------------------------------------------------------------------------------

# For building and uploading conda packages and environments
FROM stefco/llama-env:${DOCKER_TAG}-0.36.2

#------------------------------------------------------------------------------
# APPEND /etc/docker-meta.yml
COPY --from=meta /etc/docker-meta.yml /etc/new-docker-meta.yml
RUN cat /etc/new-docker-meta.yml >>/etc/docker-meta.yml \
    && echo Full meta: \
    && cat /etc/docker-meta.yml \
    && rm /etc/new-docker-meta.yml
# END APPEND /etc/docker-meta.yml
#------------------------------------------------------------------------------

# install developer tools
COPY . /root/provision
RUN ls -a ~/provision
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --default-toolchain nightly
RUN conda install \
        anaconda-client \
        conda-build \
    && pip install -r ~/provision/requirements-dev.txt \
    && pip install git+https://github.com/stefco/pypiprivate.git \
    && conda clean -y --all \
    && rm -rf ~/provision
#RUN julia -e 'using Pkg; Pkg.add("IJulia")' \
#    && rm -r ~/.julia/compiled
RUN apt-get -y update \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y --no-install-recommends \
        make \
        rsync \
        texlive-full \
    && echo Installing nodejs \
    && apt-get install -y --no-install-recommends \
        nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && jupyter labextension install \
        @jupyter-widgets/jupyterlab-manager \
        ipytree \
        @jupyterlab/toc \
        jupyterlab-drawio \
        @krassowski/jupyterlab_go_to_definition \
        @ryantam626/jupyterlab_code_formatter
