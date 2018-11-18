FROM makevoid/ruby-coffee as builder

WORKDIR /app

RUN mkdir -p /app/.bundle

ADD .bundle/config-docker .bundle/config

ADD Gemfile*  /app/
RUN bundle --deployment

ENV RACK_ENV production

RUN ls vendor

ADD .   /app

# FROM makevoid/ruby-2.5 # TODO: compile coffee in the build step
FROM makevoid/ruby-coffee
COPY --from=builder /app /app

WORKDIR /app

RUN bundle --deployment

CMD bundle exec rackup -o 0.0.0.0 -p 3000
