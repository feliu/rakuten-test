FROM ubuntu:latest
MAINTAINER Eduard Feliu "dua_rajdeep@yahoo.com"
RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential
COPY ./ /app
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 5000
CMD python ./app.py