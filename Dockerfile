FROM ubuntu:18.04

RUN apt -y update && apt install -y apt-utils

RUN DEBIAN_FRONTEND=noninteractive \
    apt install -y --no-install-recommends \
    ca-certificates \
    gcc \
    wget \
    tcl-dev \
    python

RUN mkdir /src \
 && cd /src \
 && wget https://astuteinternet.dl.sourceforge.net/project/modules/Modules/modules-4.2.4/modules-4.2.4.tar.gz

WORKDIR /src

RUN DEBIAN_FRONTEND=noninteractive \
    apt install -y --no-install-recommends \
    less

RUN tar xzf modules-4.2.4.tar.gz \
 && cd modules-4.2.4 \
 && ./configure \
 && make \
 && make install

RUN ln -s /usr/local/Modules/init/profile.sh /etc/profile.d/modules.sh \
 && ln -s /usr/local/Modules/init/profile.csh /etc/profile.d/modules.csh \
 && echo "source /usr/local/Modules/init/bash" >> ~/.bashrc \
 && echo "source /usr/local/Modules/init/bash" >> ~/.bash_profile \
 && echo ". /usr/local/Modules/init/sh" >> ~/.profile

RUN mkdir -p /src/sdss/github/modulefiles \
 && mkdir -p /src/sdss/svn/modulefiles

WORKDIR /src/sdss

ENV SDSS_INSTALL_PRODUCT_ROOT /src/sdss
ENV SDSS_GITHUB_KEY e9378cae306715fc46966f68d0600b265f6ecac1

RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    git \
    python-pip \
    subversion

RUN pip install setuptools wheel \
 && pip install pyyaml pygments requests

RUN . /usr/local/Modules/init/sh \
 && module use /src/sdss/github/modulefiles \
 && module use /src/sdss/svn/modulefiles \
 && git clone https://github.com/sdss/sdss_install.git github/sdss_install/master \
 && ./github/sdss_install/master/bin/sdss_install_bootstrap \
 && module load sdss_install \
 && svn export https://svn.sdss.org/public/repo/sdss/idlutils/tags/v5_5_33/bin/ \
 && export PATH=${PATH}:/src/sdss/bin \
 && sdss_install --public -v data/sdss/catalogs/dust v0_2

SHELL ["/bin/bash", "-c"]

RUN echo "module use /src/sdss/github/modulefiles" >> ~/.bashrc \
 && echo "module use /src/sdss/svn/modulefiles" >> ~/.bashrc \
 && echo "module load sdss_install" >> ~/.bashrc

ENV PATH ${PATH}:/src/sdss/bin

RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    gfortran

RUN svn export https://svn.sdss.org/public/repo/sdss/idlutils/tags/v5_5_33 /src/sdss/idlutils-v5_5_33

# RUN . /usr/local/Modules/init/sh \
#  && module use /src/sdss/github/modulefiles \
#  && module use /src/sdss/svn/modulefiles \
#  && module load sdss_install \
#  && sdss_install --public -v sdss/idlutils v5_5_33 \
#  && echo 1
# 
#sdss_install --public -v sdss/photoop v1_12_3


