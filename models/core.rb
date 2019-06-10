require 'json'
require_relative 'transaction'
require_relative 'raw_transaction'

# Core - Bitcoin Core RPC wrapper

class Core

  attr_reader :client

  def initialize
    @client = BitcoinClient::Client.new RPC_USER, RPC_PASSWORD, {
      host:   RPC_HOST,
      port:   RPC_PORT,
      cache:  true,
      redis:  REDIS,
    }
  end

  def address
    @client.getaccountaddress ""
  end

  def balance
    @client.balance
  end

  def balance_zeroconf
    @client.balance "", 0
  end

  def send(to, amount)
    @client.sendtoaddress to, amount
  end

  # TODO: remove - this is only for imported addresses
  def transactions
    txs = @client.listtransactions.reverse
    txs.map do |tx|
      tx = symbolize tx
      Transaction.new(
        account:         tx.f(:account),
        address:         tx.f(:address),
        category:        tx.f(:category),
        amount:          tx.f(:amount),
        vout:            tx.f(:vout),
        confirmations:   tx.f(:confirmations),
        blockhash:       tx[:blockhash],
        blockindex:      tx[:blockindex],
        blocktime:       tx[:blocktime],
        txid:            tx.f(:txid),
        keychainconflicts: tx.f(:keychainconflicts),
        time:            tx.f(:time),
        timereceived:    tx.f(:timereceived),
      )
    end
  end

  def get_transaction(tx_id)
    tx = RawTransaction.new tx_id, @client
    tx.get
  end

  def blocks_count
    info = @client.getblockchaininfo
    info.fetch "blocks"
  end

  def block_hash(block_number)
    @client.getblockhash block_number
  end

  def block(block_hash)
    @client.getblock block_hash
  end

  private

  # TODO: move

  def symbolize(hash)
    Hash[hash.map{|(k,v)| [k.to_sym,v]}]
  end

end
