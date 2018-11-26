APP_ENV = ENV["RACK_ENV"] || "development"

require 'bundler/setup'
Bundler.require :default, APP_ENV.to_sym

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

path = File.expand_path "../../", __FILE__
APP_PATH = path

DOCKER = ENV["DOCKER"] == "1"

# hosts
BCHSV = '91.121.181.140'
BTC   = '176.31.116.188'
BTC_LOCAL  = 'localhost'

DEFAULT_HOST = if "production"
  BCHSV
else
  BTC_LOCAL
end

RPC_HOST = ENV["BTC_RPC_HOST"] || DEFAULT_HOST

RPC_PORT = 8332

password = if DOCKER
  ENV["BITCOIN_RPCPASS"]
else
  # "hack" to load file locally from bitcoin.conf
  read = -> (path) { File.read File.expand_path path }
  path = "~/.bitcoin/bitcoin.conf"
  file = read.( path )
  file.strip.match(/rpcpassword=(.+)/)[1]
end

# RPC_USER     = 'bitcoinrpc'
RPC_USER     = ENV["BTC_RPC_USERNAME"] || 'bitcoin'
RPC_PASSWORD = password.strip

# TODO:
#
# rescue BitcoinClient::Errors::RPCError

# models
require_relative "../models/core"

REDIS_HOST = !DOCKER ? "localhost" : "redis"
REDIS_PORT = 6379

REDIS = unless DOCKER
  Redis.new
else
  Redis.new host: REDIS_HOST, port: REDIS_PORT
end

R = REDIS # alias

# monitoring (sentry)
if APP_ENV == "production"
  Raven.configure do |config|
    config.dsn = "https://727c1c8f6cba461d897edc9643365481:#{ENV["SENTRY_SECRET"]}@sentry.io/1330847"
  end
end
