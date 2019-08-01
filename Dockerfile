#------------------------------------------------------------------------------
# CREATE docker-meta.yml
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
RUN echo >>/docker-meta.yml "- name: ${NAME}" \
    && echo >>/docker-meta.yml "  version: ${VERSION}" \
    && echo >>/docker-meta.yml "  commit: ${COMMIT}" \
    && echo >>/docker-meta.yml "  url: ${URL}" \
    && echo >>/docker-meta.yml "  branch: ${BRANCH}" \
    && echo >>/docker-meta.yml "  date: ${DATE}" \
    && echo >>/docker-meta.yml "  repo: ${REPO}" \
    && echo >>/docker-meta.yml "  docker_tag: ${DOCKER_TAG}" \
    && echo >>/docker-meta.yml "  dockerfile_path: ${DOCKERFILE_PATH}" \
    && echo >>/docker-meta.yml "  dockerfile: |" \
    && sed >>/docker-meta.yml 's/^/    /' </provision/"${DOCKERFILE_PATH}" \
    && rm -r /provision
# END CREATE docker-meta.yml
#------------------------------------------------------------------------------

# For building and uploading conda packages and environments
FROM stefco/llama-env:${DOCKER_TAG}-0.6.0
USER root

#------------------------------------------------------------------------------
# APPEND docker-meta.yml
COPY --from=meta /docker-meta.yml /new-docker-meta.yml
RUN cat /new-docker-meta.yml >>/docker-meta.yml \
    && echo Full meta: \
    && cat /docker-meta.yml \
    && rm /new-docker-meta.yml
# END APPEND docker-meta.yml
#------------------------------------------------------------------------------

# install developer tools
COPY . /home/llama/provision
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends make rsync texlive-full \
    && rm -rf /var/lib/apt/lists/*
RUN su llama -c 'bash -i -c " \
    conda install anaconda-client conda-build \
        && mkdir -p /home/llama/.local/share \
        && mkdir -p /home/llama/.cache \
        && pip install -r /home/llama/provision/requirements-dev.txt \
        && pip install git+https://github.com/stefco/pypiprivate.git \
        && rm -r ~/miniconda3/pkgs \
    "' \
    && rm -rf /home/llama/provision
USER llama
