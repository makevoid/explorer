require 'bundler/setup'
Bundler.require :default

APP_ENV = ENV["RACK_ENV"] || "development"

path = File.expand_path "../../", __FILE__
APP_PATH = path

DOCKER = ENV["DOCKER"] == "1"

# RPC_HOST = '188.165.223.5' # sys.mkvd.net
# RPC_HOST = '212.47.233.106' # bchain  # scaleway
unless DOCKER
  RPC_HOST = 'localhost' # always localhost, localhost ftw!
  RPC_PORT = 8332
else
  RPC_HOST = 'mkvd.eu.ngrok.io' # TODO: containerize bitcoin as well that downloads the chain via torrent (TODO: upload the chain to s3)
  RPC_PORT = 80
end


read = -> (path) { File.read File.expand_path path }

# password = if APP_ENV == "development"
#   path = "~/.sys.bitcoin.conf.pw"
#   read.( path )
# else

  # local is better:

  path = "~/.bitcoin/bitcoin.conf"
  # path = "./config/.bitcoin-rpcpassword" if DOCKER
  file = read.( path )
  password = file.strip.match(/rpcpassword=(.+)/)[1]
# end

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


#--------------------------------#
#
#  Redis (using docker-compose)
#
#--------------------------------#


REDIS_HOST = !DOCKER ? "localhost" : "redis"    # incredible, huh?
REDIS_PORT = 6379

#--------------------------------#
#
#  via docker-compose:
#
#    dc build && dc up
#
#--------------------------------#

REDIS = unless DOCKER
  Redis.new
else
  Redis.new host: REDIS_HOST, port: REDIS_PORT
end

R = REDIS # shortcut
