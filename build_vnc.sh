#!/bin/sh

# build incantation to set up permissions within container to match those of the user who builds it.
# this is to facilitate writing of outputs to host directories.
docker build --build-arg USER_ID=$(id -u ${USER}) --build-arg GROUP_ID=$(id -g ${USER}) -t iraf-vnc -f Dockerfile-vnc .
