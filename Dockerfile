FROM ubuntu:xenial

WORKDIR /build

RUN apt-get update \
	&& apt-get install -y build-essential ruby-dev python-pip \
	&& pip install Pygments

env LANG=C.UTF-8
env LANGUAGE=C.UTF-8
env LC_ALL=C.UTF-8

COPY Gemfile .
COPY Gemfile.lock .

RUN gem update --system \
	&& gem install -N bundler \
	&& bundler install

COPY . .

RUN make build
