FROM python:3.9-buster

WORKDIR /app
COPY . ./

RUN python -m venv /env
ENV PATH="/env/bin:$PATH"

RUN pip install --upgrade pip
RUN pip install --no-cache-dir --upgrade -r requirements.txt

RUN bash installer.sh