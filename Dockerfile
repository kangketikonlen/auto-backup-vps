FROM ubuntu:22.04

COPY ./installer.sh /usr/local/bin
RUN /usr/local/bin/installer.sh