require 'tilt/haml'
require_relative 'config/env'

class App < Roda
  plugin(:assets,
    css: ["style.css"],
    js:  [
      "vendor/zepto.js",
      "vendor/underscore.js",
      "vendor/qrcode.js",
      "vendor/handlebars.js",
      "vendor/three.js",
      "vendor/three.flycontrols.js",
      "vendor/three.orbitcontrols.js",
      "vendor/threex.domevent.js",
      "vendor/threex.dynamictexture.js",
    ],
  )

  plugin :render, engine: "haml"
  plugin :partials
  plugin :not_found
  plugin :error_handler
  # plugin :content_for

  # TODO: move in helpers

  def json_route
    response['Content-Type'] = 'application/json'
  end

  def keychain
    @@keychain ||= Keychain.new
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

    r.root {
      r.redirect "/blocks"
    }

    r.on("blocks_new") {
      r.is {
        r.get {
          w = keychain.dev
          block_count = w.getblockcount
          hash = w.getblockhash block_count
          view "blocks_new", locals: {
            w:           w,
            block_count: block_count,
            hash:        hash,
          }
        }
      }
    }

    r.on("blocks") {
      r.is {
        r.get {
          w = keychain.dev
          block_count = w.getblockcount
          hash = w.getblockhash block_count
          view "blocks", locals: {
            w:           w,
            block_count: block_count,
            hash:        hash,
          }
        }
      }

      r.on(":block_id") { |block_id|
        r.is {
          r.get {
            json_route
            w = keychain.dev
            hash  = w.getblockhash block_id.to_i
            block = w.getblock hash
            { block: block }.to_json
          }
        }
      }
    }

    r.on("txs") {
      r.on(":tx_id") { |tx_id|
        r.is {
          r.get {
            @tx_id = tx_id
            view "tx"
          }
        }
      }
    }

    # all BC gets will be public, otherwise add if APP_ENV=="development"
    r.on("cache") {
      r.is {
        r.get {
          keys = REDIS.keys
          view "cache", locals: { keys: keys }
        }
      }

      r.on(":id") { |id|
        r.is {
          r.get {
            json_route
            { value: REDIS.get(id) }.to_json
          }
        }
      }

    }

    r.assets
  end
  # routes block end

  not_found do
    view "not_found"
  end


  error do |err|
    # self.request.status_code = 500
    puts "Error (catched by error_handler):"
    puts err.backtrace
    puts ""
    view "error", locals: { error: err }
    raise
  end
end
