FROM ubuntu:22.04

WORKDIR /app
COPY ./ /app

ENV REGION Asia/Jakarta

RUN ln -fs /usr/share/zoneinfo/${REGION} /etc/localtime

RUN apt-get update
RUN apt-get install -y software-properties-common \
	wget \
	apt-utils \
	mariadb-client \
	tzdata

RUN dpkg-reconfigure -f noninteractive tzdata

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get install -y python3.9 \
	python3.9-venv

RUN python3.9 -m venv /env

ENV PATH="/env/bin:$PATH"

RUN wget -c https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py && rm -rf get-pip.py
RUN python -m pip install --upgrade pip
RUN pip install -r requirements.txt --quiet

RUN touch .config
RUN echo "MYSQL_HOST=$MYSQL_HOST" >>.config
RUN echo "MYSQL_PORT=$MYSQL_PORT" >>.config
RUN echo "MYSQL_USER=$MYSQL_USER" >>.config
RUN echo "MYSQL_PASSWORD=$MYSQL_PASSWORD" >>.config
RUN echo "LOCAL_PATH=$(pwd)" >>.config

RUN bash start.sh