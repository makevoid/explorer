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
    hash = CORE.block_hash block_num
    block = CORE.block hash
    p hash
    p block
    block.f ""
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
