APP_ENV = ENV["RACK_ENV"] || "development"

require 'bundler/setup'
Bundler.require :default, APP_ENV.to_sym
require_relative '../lib/monkeypatches'
require_relative '../lib/app_helpers'

# encoding settings, independent from the current system lang
Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

# chain (current_chain) env variable defaults and definitions (btc and forks)
# "MAIN_CHAIN" # aka MAIN-NET (aka - the Blockchain - the one with the most cumulative pow at the moment)
MAIN_CHAIN = "MAIN_CHAIN"
BTC_CHAIN = MAIN_CHAIN # BCH_CHAIN (fork)

# main chain configuration

CURRENT_CHAIN = MAIN_CHAIN

# application path (PATH env var)

path = File.expand_path "../../", __FILE__
APP_PATH = path

# docker is enabled
DOCKER = ENV["DOCKER"] == "1"

# hosts
# ---
#
# default hosts:
#
#   hosts that accept RPC connections with the bitcoin core (bitcoind) JSON API
#   (they obviously don't offer a wallet API, means only that bitcoind is configured with `./configure --disable-wallet`)
#

# makevoid's configuration

# hosts
BTC   = '54.194.11.86'
BTC_LOCAL  = 'localhost'

DEFAULT_HOST = if APP_ENV == "production"
  BTC_LOCAL
else
  BTC_LOCAL
  BTC
end

RPC_HOST = ENV["BTC_RPC_HOST"] || DEFAULT_HOST

RPC_PORT = 8332

CHAIN_NAME = case CURRENT_CHAIN
  when MAIN_CHAIN then "Bitcoin"
  when BCH_CHAIN  then "Bitcoin Cash"
  when LTC_CHAIN  then "Litecoin"
  when BSV_CHAIN  then "BSV"
  when DOGE_CHAIN then "Dogecoin"
else
  "Bitcoin"
end

BTC_SYMBOL = case CURRENT_CHAIN
  when MAIN_CHAIN then "BTC"
  when BCH_CHAIN  then "BCH"
  when LTC_CHAIN  then "LTC"
  when BSV_CHAIN  then "BSV"
  when DOGE_CHAIN then "DOGE"
else
  "Bitcoin"
end

BTC_SYM = BTC_SYMBOL

password = if DOCKER
  ENV["BITCOIN_RPCPASS"]
else
  # "hack" to load file locally from bitcoin.conf ( ususally the dev machine is a machine with bitcoin-qt installed and synced - w/ pruning enable if necessary e.g. when dev machines are laptops )
  read = -> (path) { File.read File.expand_path path }
  path = "~/.bitcoin/bitcoin.conf"
  file = read.( path )
  file.strip.match(/rpcpassword=(.+)/)[1]
end

# RPC_USER     = 'bitcoinrpc'
RPC_USER     = ENV["BTC_RPC_USERNAME"] || 'bitcoinrpc'
RPC_PASSWORD = password.strip

# TODO:
#
# rescue BitcoinClient::Errors::RPCError

# models
require_relative "../models/core"

# Redis

REDIS_HOST = !DOCKER ? "localhost" : "redis"
REDIS_PORT = 6379

REDIS = unless DOCKER
  Redis.new
else
  Redis.new host: REDIS_HOST, port: REDIS_PORT
end

R = REDIS # alias so we can R["key"] (hash-like DSL, use redis as a remote constant #remotememory)

# Monitoring (sentry, hooks into rack)

if APP_ENV == "production"
  Raven.configure do |config|
    config.dsn = "https://727c1c8f6cba461d897edc9643365481:#{ENV["SENTRY_SECRET"]}@sentry.io/1330847"
  end
end

if APP_ENV == "devlopment"
  R.flushdb
end

include AppHelpers

require_relative 'const/const_assets'
