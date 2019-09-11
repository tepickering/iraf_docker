FROM michaelcs/astrocondairaf:latest

ARG USER_ID
ARG GROUP_ID

RUN groupadd -f -g ${GROUP_ID} iraf && \
    useradd -l -u ${USER_ID} -g iraf iraf

RUN mkdir -p /home/iraf && chown -R iraf:iraf /home/iraf

USER iraf
ENV HOME /home/iraf

RUN /bin/bash -c "cd /home/iraf && source activate iraf27 && mkiraf -f"
