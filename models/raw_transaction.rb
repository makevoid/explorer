class RawTransaction

  attr_reader :tx_id

  def initialize(tx_id, client)
    @tx_id  = tx_id
    @client = client
  end

  def get
    raw_tx = getrawtransaction tx_id
    decoderawtransaction raw_tx
  end

  private

  def getrawtransaction(tx_id)
    x = @client.getrawtransaction tx_id
  end

  def decoderawtransaction(raw_tx)
    @client.decoderawtransaction raw_tx
  end

end
