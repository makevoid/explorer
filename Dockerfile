FROM makevoid/ruby-coffee

ADD Gemfile      /app
ADD Gemfile.lock /app
RUN bundle

ADD .     /app
RUN cp /app/config/.bitcoin-rpcpassword.default /app/config/.bitcoin-rpcpassword  &&  \
    bundle

CMD bundle exec rackup -o 0.0.0.0
