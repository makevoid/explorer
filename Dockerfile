FROM makevoid/ruby-coffee as builder

ADD Gemfile      /app
ADD Gemfile.lock /app
RUN bundle --without development test

ENV RACK_ENV production
ENV BITCOIN_RPCPASS ${BITCOIN_RPCPASS}

ADD Gemfile*  /app/

WORKDIR /app

RUN mkdir -p /app/config && echo "$BITCOIN_RPCPASS" > /app/config/.bitcoin-rpcpassword &&  bundle

FROM makevoid/ruby-2.5
COPY --from=builder /app /app

WORKDIR /app
ADD .   /app

CMD bundle exec rackup -o 0.0.0.0
