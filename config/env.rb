require 'bundler/setup'
Bundler.require :default

APP_ENV = ENV["RACK_ENV"] || "development"

path = File.expand_path "../../", __FILE__
APP_PATH = path

RPC_HOST = '188.165.223.5' # sys.mkvd.net
# RPC_HOST = '212.47.233.106' # bchain  # scaleway
# RPC_HOST = 'localhost'


read = -> (path) { File.read File.expand_path path }

password = if APP_ENV == "development"
  path = "~/.sys.bitcoin.conf.pw"
  read.( path )
else
  path = "~/.bitcoin/bitcoin.conf"
  file = read.( path )
  file.strip.match(/rpcpassword=(.+)/)[1]
end

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
