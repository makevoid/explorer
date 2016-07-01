FROM ruby:2.3

RUN apt-get update
RUN apt-get install -y git nodejs npm && \
    npm install coffee-script

RUN mkdir /app
WORKDIR   /app

ADD Gemfile      /app
ADD Gemfile.lock /app

ENV BUNDLE_PATH /tmp/bundle
RUN bundle install

ENV RACK_ENV production
ENV DOCKER   1

ADD .     /app

EXPOSE 4567

RUN bundle install
CMD ["bundle", "exec", "rackup", "-p", "4567", "-o", "0.0.0.0"]
