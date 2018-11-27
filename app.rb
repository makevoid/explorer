require 'tilt/haml'
require_relative 'config/env'

class App < Roda

  DEV_ASSETS = if APP_ENV == "production"
    []
  else
    %w(
      vendor/three.js
      vendor/three.flycontrols.js
      vendor/three.orbitcontrols.js
      vendor/three.domevent.js
      vendor/three.dynamictexture.js
      vendor/three.orbitcontrols.js
      vendor/three.orbitcontrols.js
      vendor/qrcode.js
    )
  end

  plugin(:assets,
    css: ["style.css"],
    js:  %w(
      vendor/jquery.js
      vendor/underscore.js
      vendor/underscore.string.js
      vendor/handlebars.js
      vendor/moment.js
      blocks.js
    ).merge(DEV_ASSETS),
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
  use Raven::Rack if APP_ENV == "production"

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

    CORE = Core.new unless defined?(CORE)

    cache = -> (cache_key, function, time) {
      if R.get cache_key
        R.get cache_key
      else
        value = function.()
        R.setex cache_key, time, value
        value
      end
    }

    BLOCKS_COUNT = -> { cache.("cache:blocks_count", -> { CORE.blocks_count }, 30).to_i } unless defined?(BLOCKS_COUNT)

    r.on("api") {
      json_route

      r.is('blocks', Integer) { |block_id|
        r.get {
          begin
            hash = CORE.block_hash block_id
          rescue BitcoinClient::Errors::RPCError => e
            error_msg = e.message.match /"message"=>"(?<message>.+)"/
            error_msg = error_msg[:message] if error_msg
            # TODO: if =~ /block height ouf of range/i --- enhance the error
            r.halt(404, { error: error_msg }.to_json)
          end
          r.etag hash, weak: true
          block = CORE.block hash
          { block: block }.to_json
        }
      }

      r.is('blocks_latest_num') {
        r.get {
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
      r.get {
        block_count = BLOCKS_COUNT.()
        begin
          hash = CORE.block_hash block_id
        rescue BitcoinClient::Errors::RPCError => e
          r.halt 404, :block_not_found
        end
        view "blocks", locals: {
          block_count: block_count,
          block_curr:  block_id,
          hash:        hash,
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
        tx = CORE.get_transaction tx_id
        view "tx", locals: { tx: tx, tx_id: tx_id }
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

    if APP_ENV == "development"
      r.on("blocks_new") {
        r.get {
          begin
            block_count = BLOCKS_COUNT.()
          rescue Errno::ECONNREFUSED => e
            r.halt :error
          end

          hash = CORE.block_hash block_count
          view "blocks_new", locals: {
            block_count: block_count,
            block_curr:  block_count,
            hash:        hash,
          }
        }
      }
    end

    r.assets
  end

  not_found do
    view "not_found"
  end

  error do |err|
    puts "Error (catched by error_handler):"
    puts err.backtrace
    puts ""
    view "error", locals: { error: err }
    raise
  end
end
