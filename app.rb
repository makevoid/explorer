require 'tilt/haml'
require_relative 'config/env'

class App < Roda
  plugin(:assets,
    css: ["style.css"],
    js:  ["vendor/zepto.js", "vendor/underscore.js", "vendor/qrcode.js", "vendor/handlebars.js"],
  )

  plugin :render, engine: "haml"
  plugin :partials
  plugin :not_found
  # plugin :content_for

  # TODO: move in helpers

  def json_route
    response['Content-Type'] = 'application/json'
  end

  def wallet
    @@wallet ||= Wallet.new
  end

  def params
    symbolize request.params
  end

  # monkeypatches

  def symbolize(hash)
    Hash[hash.map{|(k,v)| [k.to_sym,v]}]
  end

  # view

  def body_class
    request.path.split("/")[1]
  end

  def js_void
    "javascript:void(0)"
  end

  def table_row(text, colspan: 5)
    haml_tag(:tr) do
      haml_tag(:td, colspan: colspan) do
        haml_concat text
      end
    end
  end

  def content_for(key, &block)
    if block
      @content_for ||= {}
      @content_for[key] = yield
    else
      @content_for && @content_for[key]
    end
  end

  route do |r|
    @time = Time.now

    r.root do
      r.redirect "/blocks"
    end

    r.on "blocks" do
      r.is do
        r.get do
          view "blocks"
        end
      end

      r.on ":block_count" do |block_count|
        r.is do
          r.get do
            json_route
            w = wallet.dev
            hash = w.getblockhash block_count.to_i
            block = w.getblock hash
            { block: block }.to_json
          end
        end
      end
    end

    # all BC gets will be public, otherwise add if APP_ENV=="development"
    r.on "cache" do
      r.is do
        r.get do
          view "cache"
        end
      end

      redis = Redis.new

      r.on ":id" do |id|
        r.is do
          r.get do
            json_route
            { value: redis.get(id) }.to_json
          end
        end
      end

    end

    r.assets
  end

  not_found do
    view "not_found"
  end
end
