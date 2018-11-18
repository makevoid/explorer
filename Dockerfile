FROM makevoid/ruby-coffee as builder

ADD Gemfile*  /app/
RUN bundle --without development test

ENV RACK_ENV production

FROM makevoid/ruby-2.5
COPY --from=builder /app /app

WORKDIR /app
ADD .   /app

CMD bundle exec rackup -o 0.0.0.0
