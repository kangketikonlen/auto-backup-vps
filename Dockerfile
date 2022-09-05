FROM ubuntu:22.04

ENV REGION Asia/Jakarta

RUN apt-get update
RUN apt-get install -y software-properties-common \
	wget \
	tzdata

RUN ln -fs /usr/share/zoneinfo/${REGION} /etc/localtime && \
	dpkg-reconfigure -f noninteractive tzdata

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get install -y python3.9 \
	python3.9-venv

RUN wget -c https://bootstrap.pypa.io/get-pip.py
RUN python3.9 get-pip.py && rm -rf get-pip.py