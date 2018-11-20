require 'tilt/haml'
require_relative 'config/env'

# TODO: move
#
# Bitcoin
#
#
#
# class Bitcoin
#
# ...

class Bitcoin
  def self.status
    "synchronizing - x blocks remaining"
  end
end

class App < Roda
  plugin(:assets,
    css: ["style.css"],
    js:  [
      "vendor/zepto.js",
      "vendor/underscore.js",
      "vendor/underscore.string.js",
      "vendor/handlebars.js",
      "blocks.js",
      # "vendor/three.js",
      # "vendor/three.flycontrols.js",
      # "vendor/three.orbitcontrols.js",
      # "vendor/threex.domevent.js",
      # "vendor/threex.dynamictexture.js",
    ],
  )

  plugin :render, engine: "haml"
  plugin :partials
  plugin :not_found
  plugin :error_handler
  plugin :halt
  plugin :symbol_views
  # plugin :content_for

  plugin :public

  plugin :caching

  use Rack::Deflater

  # TODO: move in helpers

  def json_route
    response['Content-Type'] = 'application/json'
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

    r.public if APP_ENV == "development"

    r.root {
      r.redirect "/blocks"
    }

    # r.on("blocks_new") {
    #   r.is {
    #     r.get {

    #       block_count = BLOCKS_COUNT.()
    #       hash = CORE.block_hash block_count
    #       view "blocks_new", locals: {

    #         block_count: block_count,
    #         hash:        hash,
    #       }
    #     }
    #   }
    # }

    CORE = Core.new

    cache = -> (cache_key, function, time) {
      if R.get cache_key
        R.get cache_key
      else
        value = function.()
        R.setex cache_key, time, value
        value
      end
    }

    BLOCKS_COUNT = -> { cache.("cache:blocks_count", -> { CORE.blocks_count }, 360).to_i } # 3 minutes

    r.on("api") {
      json_route

      r.is('blocks', Integer) { |block_id|
        r.get {
          hash  = CORE.block_hash block_id
          r.etag hash, weak: true
          block = CORE.block hash
          { block: block }.to_json
        }
      }

      r.is('blocks_latest_num') {
        r.get {
          CORE = keychain.dev
          block_count = BLOCKS_COUNT.()
          { block_num: block_count }.to_json
        }
      }

      r.is('txs', String) { |tx_id|
        r.get {
          tx = CORE.get_transaction tx_id
          { tx: tx }.to_json
        }
      }

    }

    r.is('blocks', Integer) { |block_id|
      r.is {
        r.get {
          block_count = BLOCKS_COUNT.()
          hash = CORE.block_hash block_id
          view "blocks", locals: {
            block_count: block_count,
            block_curr:  block_id,
            hash:        hash,
          }
        }
      }
    }

    r.on("blocks") {

      begin
        block_count = BLOCKS_COUNT.()
      rescue Errno::ECONNREFUSED => e
        r.halt :error
      end

      r.is {
        r.get {
          hash = CORE.block_hash block_count
          view "blocks", locals: {
            block_count: block_count,
            block_curr:  block_count,
            hash:        hash,
          }
        }
      }

      r.on("hashes") { |hash|
        r.is {
          r.on(":block_hash") { |block_hash|
            r.get {
              view "blocks", locals: {
                block_count: block_count,
                hash:        block_hash,
              }
            }
          }
        }
      }
    }

    r.is('txs', String) { |tx_id|
      r.get {
        @tx_id = tx_id
        view "tx"
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
