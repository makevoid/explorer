require 'bundler/setup'
Bundler.require :default

APP_ENV = ENV["RACK_ENV"] || "development"

path = File.expand_path "../../", __FILE__
APP_PATH = path

DOCKER = ENV["DOCKER"] == "1"

BCHSV1 = '91.121.181.140'
BCHSV2 = '176.31.116.188'

RPC_HOST = ENV["BTC_RPC_HOST"] || BCHSV2

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
