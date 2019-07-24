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
COPY "${DOCKERFILE_PATH}" /provision
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
FROM stefco/llama-env:${DOCKER_TAG}
USER root

#------------------------------------------------------------------------------
# APPEND docker-meta.yml
COPY --from=meta /docker-meta.yml /new-docker-meta.yml
RUN cat /new-docker-meta.yml >>/docker-meta.yml && rm /new-docker-meta.yml
# END APPEND docker-meta.yml
#------------------------------------------------------------------------------

# install developer tools
COPY . /home/llama/provision
RUN apk --no-cache add vim make rsync texlive-full \
    && su llama -c 'bash -i -c " \
        conda install anaconda-client conda-build \
            && pip install -r /home/llama/provision/requirements-dev.txt \
            && pip install git+https://github.com/stefco/pypiprivate.git \
            && rm -r ~/miniconda3/pkgs \
    "' \
    && rm -rf /home/llama/provision
USER llama
