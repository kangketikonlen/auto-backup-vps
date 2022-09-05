FROM python:3.9-buster
WORKDIR /app
COPY . ./

RUN adduser --disabled-password --no-create-home --gecos "" abvps
RUN pip install --upgrade pip
RUN python -m pip install --upgrade pip
RUN pip install --no-cache-dir --upgrade -r requirements.txt

USER abvps