# Low-Latency Algorith for Multi-messenger Astrophysics (LLAMA) Conda build environment
![Anaconda environment
used](https://anaconda.org/stefco/llama-py37/badges/version.svg) ![Docker build status](https://img.shields.io/docker/cloud/build/stefco/llama-dev.svg?style=flat-square)

[LLAMA](http://multimessenger.science) is a reliable and flexible multi-messenger astrophysics framework and search pipeline. It identifies astrophysical signals by combining observations from multiple types of astrophysical messengers and can either be run in online mode as a self-contained low-latency pipeline or in offline mode for post-hoc analyses. It is maintained by [Stefan Countryman](https://stc.sh) from [this github repository](https://github.com/stefco/llama-env); the Docker image can be found [here](https://cloud.docker.com/repository/registry-1.docker.io/stefco/llama-env). Some
documentation on manually pushing the [Conda environment](https://anaconda.org/stefco/environments) is available
[here](http://docs.anaconda.com/anaconda-cloud/user-guide/tasks/work-with-environments/).

This repository houses images that can be used for development work with LLAMA.
If you have the LLAMA source code checked out in, e.g.,
`/home/yourname/llama-code`, you can start developing using e.g. the python 3.7
version of this image with:

```
docker run -v /home/yourname/llama-code:/home/llama/multimessenger-science \
    -it stefco/llama-base:py37 bash
```

You can also build and deploy code or documentation to e.g.
[PyPI](http://pypi.org) or [Anaconda.org](http://anaconda.org) (or your own
private versions thereof) using these images.
