#!/bin/bash

mkdir -p new-site/app

# Dockerfile を作成
echo "FROM tiangolo/uvicorn-gunicorn-fastapi:python3.7

COPY ./app /app" >new-site/Dockerfile

# main.py をダウンロード
wget -O new-site/app/main.py "https://gist.githubusercontent.com/takapiro99/c9530b6ae04b0dc9777fa437fde76dde/raw/72537387d664e8697fbb35f05eea85c167c13b34/main.py"

# docker-compose.yml を作成
echo "version: '3'

services:
  app:
     build: .
    volumes:
      - ./app:/app
    ports:
      - '5000:80'
" >new-site/docker-compose.yml

echo '

    >=>                                >=>
    >=>                                >=>
    >=>    >=>     >==>>==>    >==>    >=>
 >=>>=>  >=>  >=>   >=>  >=> >>   >=>  >>
>>  >=> >=>    >=>  >=>  >=> >>===>>=> >>
>>  >=>  >=>  >=>   >=>  >=> >>
 >=>>=>    >=>     >==>  >=>  >====>   >=>

'
