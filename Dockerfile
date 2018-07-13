FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda2-5.2.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc



# Install TensorFlow
RUN conda install tensorflow-gpu


# Install Turicreate
RUN apt-get install -y libblas3 liblapack3 libstdc++6
RUN pip install turicreate
RUN pip uninstall -y mxnet
RUN pip install mxnet-cu80==1.1.0

# Expose Ports for TensorBoard (6006), Ipython (8888)
EXPOSE 6006 8888

RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

COPY entrypoint.sh /usr/local/bin/entrypoint.sh


# Install additional libs
RUN conda install -c conda-forge jupyter_full_width jupyter_nbextensions_configurator jupyter_contrib_nbextensions jupyterthemes

RUN conda install -c anaconda keras-gpu opencv caffe theano


RUN pip install coremltools
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

