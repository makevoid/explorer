source "http://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "haml"
gem "roda"

gem "redis"

# gem "bitcoin-client", path: "~/apps/bitcoin-client"
gem "bitcoin-client", github: "makevoid/bitcoin-client"

gem 'hashie', require: "hashie/mash"

gem 'identicon'

gem 'rqrcode', github: "makevoid/rqrcode" # SVG viewbox

group :development, :production do
  gem "puma"
end

group :development do
  gem "rerun"
  gem "guard"
  gem "guard-coffeescript"
  gem "oj"
end

group :production do
  gem "sentry-raven"
end
