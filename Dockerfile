# based on tutorials:
# https://medium.com/@chadlagore/conda-environments-with-docker-82cdc9d25754
# https://docs.docker.com/get-started/part2/

# Conda's python 3.7 distribution
# https://github.com/ContinuumIO/docker-images/tree/master/miniconda3
# FROM continuumio/miniconda3
# https://hub.docker.com/_/debian/
FROM debian:stretch

# set up anaconda for user 'llama'
# http://www.science.smith.edu/dftwiki/index.php/Tutorial:_Docker_Anaconda_Python_--_4
RUN adduser --disabled-password --gecos '' llama
RUN apt-get -y update
RUN apt-get -y install curl sudo bzip2 ncdu man git
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# switch to user 'llama'
USER llama

# Set the working directory to /app
WORKDIR /home/llama

# install conda
RUN chmod a+rwx /home/llama
RUN curl -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b -f -p /home/llama/miniconda3
RUN rm Miniconda3-latest-Linux-x86_64.sh

ENV OLDPATH "$PATH"
ENV PATH /home/llama/miniconda3/bin:"$PATH"

# update conda
RUN conda update conda
# RUN conda update miniconda3
RUN conda update --all

# install ligo environment
# based on ligo conda environment at
# https://git.ligo.org/lscsoft/conda/raw/master/environment-py36.yml
COPY llama-py37.yml .
RUN conda config --add channels conda-forge
RUN conda env create -f llama-py37.yml
RUN rm llama-py37.yml
RUN conda init bash
RUN echo 'conda activate llama-py37' >>~/.bashrc
RUN cat ~/.bashrc

# install llama requirements
COPY requirements.txt .
ENV PATH "$OLDPATH"
RUN bash -i -c 'pip install -r requirements.txt'
RUN rm requirements.txt

# install git-lfs
USER root
RUN curl -s \
        https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh \
        | sudo bash
RUN apt-get -y install git-lfs
USER llama
RUN git lfs install
USER root

# Install llama
COPY . /home/llama/multimessenger-pipeline
WORKDIR /home/llama/multimessenger-pipeline
USER root
RUN chown -R llama:llama /home/llama
USER llama
# RUN bash -i -c "python setup.py develop"
        # llama --help; \
        # make test; \

# Make port 80 available to the world outside this container
# EXPOSE 80gg

# Run app.py when the container launches
# CMD ["python", "app.py"]
