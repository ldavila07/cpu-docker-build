
FROM nvidia/cuda:9.0-devel-ubuntu16.04

ENV CUDNN_VERSION 7.1.2.21
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN mkdir -p /data && \
        mkdir -p /gen

# install
RUN \
        apt-get update && apt-get install -y --no-install-recommends \
            libcudnn7=$CUDNN_VERSION-1+cuda9.0 \
            libcudnn7-dev=$CUDNN_VERSION-1+cuda9.0 \
        autoconf \
        automake \
        libtool \
        build-essential \
        ca-certificates \
        git && \
        rm -rf /var/lib/apt/lists/*


RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.4.10-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

RUN conda install -c anaconda pillow beautifulsoup4 

# Get data
WORKDIR data/

RUN \
        git clone https://github.com/loretoparisi/darknet && \
        wget http://vision.stanford.edu/aditya86/ImageNetDogs/images.tar && \
        tar -xvf images.tar && \
        wget http://vision.stanford.edu/aditya86/ImageNetDogs/annotation.tar && \
        tar -xvf annotation.tar

# Process data
WORKDIR gen/
RUN  git clone https://github.com/ldavila07/gpu-test && \
    python gen-images.py  /data/Images/ /data/Annotation/

 # Build Darknet    
WORKDIR darknet/
RUN  git clone https://github.com/loretoparisi/darknet 
COPY ./Makefile ./
RUN \
        sed -i 's/GPU=.*/GPU=1/' Makefile && \
        make

CMD nvidia-smi -q
# defaults command
CMD ["bash"]