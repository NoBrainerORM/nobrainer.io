FROM ruby:2.7-alpine3.15

WORKDIR /build

RUN apk --update add build-base python2 py-pip \
	&& pip install Pygments

env LANG=C.UTF-8
env LANGUAGE=C.UTF-8
env LC_ALL=C.UTF-8

COPY Gemfile* ./

RUN gem update --system 3.2.3 \
	&& gem install -N bundler \
	&& bundler install

COPY . .

RUN make build
