FROM python:3.12.3-slim-bookworm

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt 

RUN \
    apt-get update \&& apt-get install --no-install-recommends -y 

RUN python3 -m pip install --upgrade pip

RUN python3 -m pip install -r /app/requirements.txt

EXPOSE 8000

COPY . /app/
