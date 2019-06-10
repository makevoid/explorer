require_relative 'config/env'

module Utils
  def setup!
    R.flushdb
  end

  def print_keys
    keys = R.keys "*"
    puts "R.keys", keys[0..10].inspect, "\n"
  end
end

module ProcessBlocks

  def process_block(block_num:)
    block_id  = CORE.block_hash block_num
    block     = CORE.block block_id
    # p hash
    # p block
    txs = block.f "tx"
    txs.each do |tx|
      process_tx tx_id: tx
    end
  end

  def get_outputs(tx:)
    outputs = tx.f("vout") || []
    outputs.each do |output|
      value = output.f("value")
      next if value <= 0
      script = output.f "scriptPubKey"
      addresses = script.f "addresses"
      if addresses.size > 1
        puts "TX: \n\n#{tx.inspect}\n\n"
        raise "WTF? multiple addresses? terminating, look up ^^^^"
      end
      address = addresses.first
      p value
      p address
      require 'pp'
      pp tx

      exit
    end
  end

  def process_tx(tx_id:)
    tx = CORE.get_transaction tx_id
    outs = get_outputs tx: tx

    # "balances:1Address"
    # R["balances:#{address}"] = 123

    # "addresses"
    # R["addresses"] = ["1address", "2address", ...] # set (not kv ofc)
    # R.sadd "addresses", "addr"

    # "transactions:1Address"
    # R["transactions:#{address}"] = ["tx1", "tx2", ...] # set (not kv ofc)
    # R.sadd "transactions:#{address}", "tx"


  end

end

include Utils
include ProcessBlocks

setup!
CORE = Core.new
print_keys

blocks_last = CORE.blocks_count
puts "blocks_last", blocks_last, "\n"

blocks_last.downto(0).each do |block_num|
  puts "block_num", block_num, "\n"
  process_block block_num: block_num
end
