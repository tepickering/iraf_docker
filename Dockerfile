FROM centos:7

ARG USER_ID
ARG GROUP_ID

RUN yum -y update && \
yum -y install wget libX11 libX11.i686 libXft libXft.i686

RUN wget https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh && sh Miniconda2-latest-Linux-x86_64.sh -b -p /miniconda2

RUN /bin/bash -c "/miniconda2/bin/conda init bash && \
source ~/.bashrc && \
conda update -n base -c defaults conda && \
conda update -y --all && \
conda config --add channels http://ssb.stsci.edu/astroconda && \
conda create -y -n iraf27 python=2.7 iraf-all pyraf-all stsci notebook iraf-os-libs -c astroconda && \
conda clean -y --all \
"

RUN groupadd -f -g ${GROUP_ID} iraf && \
    useradd -l -u ${USER_ID} -g iraf iraf

RUN mkdir -p /home/iraf && chown -R iraf:iraf /home/iraf

USER iraf
ENV HOME /home/iraf

RUN /bin/bash -c "/miniconda2/bin/conda init bash"
RUN /bin/bash -c "cd /home/iraf && source .bashrc && conda activate iraf27 && mkiraf -f"
