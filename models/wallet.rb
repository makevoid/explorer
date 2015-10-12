require 'json'
require_relative 'transaction'

class Wallet

  def initialize
    @client = BitcoinClient::Client.new 'bitcoinrpc', RPC_PASSWORD, {
      host: RPC_HOST,
      cache: true,
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
        walletconflicts: tx.fetch(:walletconflicts),
        time:            tx.fetch(:time),
        timereceived:    tx.fetch(:timereceived),
      )
    end
  end

  if APP_ENV == "development"
    # shortcircuit api

    def dev
      @client
    end
  end

  private

  # TODO: move

  def symbolize(hash)
    Hash[hash.map{|(k,v)| [k.to_sym,v]}]
  end

end
