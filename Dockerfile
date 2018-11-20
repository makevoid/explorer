FROM ubuntu:cosmic as ruby

RUN apt update -y
RUN apt install -y ruby-dev git
RUN gem i bundler


FROM ruby as ruby-build

RUN apt install -y build-essential


FROM ruby-build as builder

WORKDIR /app

RUN mkdir -p /app/.bundle

ADD .bundle/config-docker .bundle/config

ADD Gemfile*  /app/
RUN bundle --deployment

ENV RACK_ENV production

RUN ls vendor

ADD .   /app

FROM ruby
COPY --from=builder /app /app

WORKDIR /app

CMD bundle exec rackup -o 0.0.0.0 -p 3000
