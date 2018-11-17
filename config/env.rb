require 'bundler/setup'
Bundler.require :default

APP_ENV = ENV["RACK_ENV"] || "development"

path = File.expand_path "../../", __FILE__
APP_PATH = path

DOCKER = ENV["DOCKER"] == "1"

unless DOCKER
  RPC_HOST = 'localhost' # always localhost, localhost ftw!
else
  RPC_HOST = '91.121.181.140'
end

RPC_PORT = 8332

read = -> (path) { File.read File.expand_path path }

path = "~/.bitcoin/bitcoin.conf"
# path = "./config/.bitcoin-rpcpassword" if DOCKER
file = read.( path )
password = file.strip.match(/rpcpassword=(.+)/)[1]

# RPC_USER     = 'bitcoinrpc'
RPC_USER     = 'bitcoin'
RPC_PASSWORD = password.strip

# TODO:
#
# rescue
#
# BitcoinClient::Errors::RPCError


# models
require_relative "../models/keychain"


# lib
# require_relative "../lib/stuff"


REDIS_HOST = !DOCKER ? "localhost" : "redis"
REDIS_PORT = 6379

REDIS = unless DOCKER
  Redis.new
else
  Redis.new host: REDIS_HOST, port: REDIS_PORT
end

R = REDIS # alias
