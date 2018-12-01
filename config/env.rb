APP_ENV = ENV["RACK_ENV"] || "development"

require 'bundler/setup'
Bundler.require :default, APP_ENV.to_sym

# encoding settings, independent from the current system lang
Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

# chain (current_chain) env variable defaults and definitions (btc and forks)
MAINNET = "MAINNET_CHAIN" # aka (the Blockchain - the one with the most cumulative pow at the moment)
MAINNET_CHAIN = "MAINNET_CHAIN"
BTC_CHAIN = MAINNET # BCH_CHAIN (fork)
BCH_ABC_CHAIN = "BCH_ABC_CHAIN" # BCH_CHAIN (fork)
BCH_SV_CHAIN  = "BCH_SV_CHAIN"  # BCH_CHAIN (fork)

# configuration

CURRENT_CHAIN = BCH_CHAIN


# --------

# application path (PATH env var)
path = File.expand_path "../../", __FILE__
APP_PATH = path

# docker is enabled
DOCKER = ENV["DOCKER"] == "1"

# --------

# hosts
# ---
#
# default hosts:
#
#   hosts that accept RPC connections with the bitcoin core (bitcoind) JSON API
#   (they obviously don't offer a wallet API, means only that bitcoind is configured with `./configure --disable-wallet`)
#

BCHSV = '91.121.181.140'
BTC   = '176.31.116.188'
BTC_LOCAL  = 'localhost'

DEFAULT_HOST = if APP_ENV == "production"
  BCHSV
else
  BTC
  BTC_LOCAL
end

RPC_HOST = ENV["BTC_RPC_HOST"] || DEFAULT_HOST

RPC_PORT = 8332

# note: I'll be releasing a btc core explorer
CHAIN_NAME = if APP_ENV == "production"
  "Bitcoin SV"
else
  "Bitcoin"
end

BTC_SYMBOL = if APP_ENV == "production"
  "BCH (SV)"
else
  "BTC"
end

BTC_SYM = BTC_SYMBOL

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
