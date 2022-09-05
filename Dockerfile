FROM python:3.9-buster

RUN adduser --disabled-password --gecos "" abvps
USER abvps

WORKDIR /app
COPY . ./

RUN python -m venv /env
RUN /env/bin/pip install --upgrade pip
RUN /env/bin/pip install --no-cache-dir --upgrade -r requirements.txt

ENV PATH="/env/bin:$PATH"