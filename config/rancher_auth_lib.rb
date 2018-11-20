require 'net/http'
require_relative 'env_lib'
Env.load!

module RancherAuthLib

  def basic_auth
    user, pass = Env["RANCHER_ACCESS_KEY"], Env["RANCHER_SECRET_KEY"]
    "Basic #{["#{user}:#{pass}"].pack("m*").gsub /\n/, ''}"
  end

  def get(url)
    uri = URI url
    req = Net::HTTP::Get.new uri
    req['Authorization'] = basic_auth
    resp = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
    Oj.load resp.body
  end

  def post(url, params)
    params = Oj.dump params
    uri = URI url
    req = Net::HTTP::Post.new uri
    req.body = params
    req["Content-Type"]  = "application/json"
    req['Authorization'] = basic_auth
    resp = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
    resp = Oj.load resp.body
    resp
  end

end
