FROM ubuntu:xenial

WORKDIR /build

RUN apt-get update
RUN apt-get install -y build-essential ruby-dev

RUN apt-get -y install python-pip
RUN pip install Pygments

env LANG=C.UTF-8
env LANGUAGE=C.UTF-8
env LC_ALL=C.UTF-8

RUN gem install -N bundler

COPY Gemfile .
COPY Gemfile.lock .

RUN bundler install

COPY . .

RUN make build
