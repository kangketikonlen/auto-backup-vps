FROM python:3.9-buster

RUN adduser --disabled-password --gecos "" abvps
USER abvps

WORKDIR /app
COPY . ./

RUN pip install --upgrade pip
RUN python -m pip install --upgrade pip
RUN pip install --no-cache-dir --upgrade -r requirements.txt