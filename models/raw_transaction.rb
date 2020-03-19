class RawTransaction

  attr_reader :tx_id

  def initialize(tx_id, client)
    @tx_id  = tx_id
    @client = client
  end

  def get
    getrawtransaction tx_id
  end

  private

  def getrawtransaction(tx_id)
    @client.getrawtransaction tx_id, 1
  end

  def op_returns
    tx = get
    tx["vout"].map do |output|
      output["scriptPubKey"]["asm"]
    end.select do |script_sig|
      script_sig[0..8] == "OP_RETURN"
    end.map do |op_return|
      decode_hex op_return
    end
  end

  def decode_hex(string)
    string.map { |x| x.to_i(16).chr }.join
  end

end
