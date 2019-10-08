FROM tepickering/iraf-base:latest

MAINTAINER T. E. Pickering "te.pickering@gmail.com"

ARG USER_ID
ARG GROUP_ID

RUN groupadd -f -g ${GROUP_ID} iraf && \
    useradd -l -u ${USER_ID} -g iraf iraf

RUN mkdir -p /home/iraf && chown -R iraf:iraf /home/iraf

USER iraf
ENV HOME /home/iraf

RUN /bin/bash -c "/miniconda2/bin/conda init bash"
RUN /bin/bash -c 'cd /home/iraf && source .bashrc && conda activate iraf27 && printf "xgterm\n" | mkiraf'
