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

  def transactions
    txs = @client.listtransactions.reverse
    txs.map do |tx|
      tx = symbolize tx
      Transaction.new(
        account:         tx.fetch(:account),
        address:         tx.fetch(:address),
        category:        tx.fetch(:category),
        amount:          tx.fetch(:amount),
        vout:            tx.fetch(:vout),
        confirmations:   tx.fetch(:confirmations),
        blockhash:       tx[:blockhash],
        blockindex:      tx[:blockindex],
        blocktime:       tx[:blocktime],
        txid:            tx.fetch(:txid),
        keychainconflicts: tx.fetch(:keychainconflicts),
        time:            tx.fetch(:time),
        timereceived:    tx.fetch(:timereceived),
      )
    end
  end

  def get_transaction(tx_id)
    tx = RawTransaction.new tx_id, @client
    tx.get
  end

  def blocks_count
    @client.getblockcount
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
