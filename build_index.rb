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
      # TODO: don't reprocess already processed tx
      process_tx tx_id: tx
    end
  end

  def process_input(input)
    return if input["coinbase"]
    script = Bitcoin::Script.new input.f("scriptSig").f("asm")
    address = script.get_pubkey_address
    # get original tx to get corresponding output (and output value)
    tx = CORE.get_transaction input.f "txid"
    outputs = tx.f("vout") || []
    output = outputs.find do |output|
      output.f("n") == input.f("vout")
    end
    value = output.f "value"
    value = to_satoshis value
    R.decrby "balances:#{address}", value.to_i
  end

  def process_output(output)
    value = output.f("value")
    return if value <= 0
    script = output.f "scriptPubKey"
    addresses = script.f "addresses"
    if addresses.size > 1
      puts "TX: \n\n#{tx.inspect}\n\n"
      raise "WTF? multiple addresses? terminating, look up ^^^^"
    end
    address = addresses.first
    value = to_satoshis value
    R.incrby "balances:#{address}", value
  end

  def process_tx(tx_id:)
    return if tx_id == "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b" # genesis tx
    tx = CORE.get_transaction tx_id

    # require 'pp'
    # pp tx

    inputs  = tx.f("vin") || []
    outputs = tx.f("vout") || []

    inputs.each do |input|
      process_input input
    end

    outputs.each do |output|
      process_output output
    end

    # "balances:1Address"
    # R["balances:#{address}"] = 123

    # "addresses"
    # R["addresses"] = ["1address", "2address", ...] # set (not kv ofc)
    # R.sadd "addresses", "addr"

    # "transactions:1Address"
    # R["transactions:#{address}"] = ["tx1", "tx2", ...] # set (not kv ofc)
    # R.sadd "transactions:#{address}", "tx"
  end

  def to_satoshis(value)
    (value * 10**8).to_i
  end

end

include Utils
include ProcessBlocks

setup!
CORE = Core.new
print_keys

blocks_last = CORE.blocks_count
puts "blocks_last", blocks_last, "\n"

start = 0
# start = 169
start.upto(blocks_last).each do |block_num|
  puts "block_num", block_num, "\n"
  process_block block_num: block_num
end
