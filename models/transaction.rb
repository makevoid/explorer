class Transaction
  attr_reader :account, :address, :category, :amount, :vout, :confirmations, :blockhash, :blockindex, :blocktime, :txid, :conflicts, :time, :timereceived

  def initialize(account:, address:, category:, amount:, vout:, confirmations:, blockhash:, blockindex:, blocktime:, txid:, keychainconflicts:, time:, timereceived:)
    @account       = account
    @address       = address
    @category      = category
    @amount        = amount
    @vout          = vout
    @confirmations = confirmations
    @blockhash     = blockhash
    @blockindex    = blockindex
    @blocktime     = blocktime
    @txid          = txid
    @conflicts     = keychainconflicts
    @time          = time
    @timereceived  = timereceived
  end

  def tx_id_short
    "#{txid[0..6]}...#{txid[-3..-1]}"
  end

  def time_s
    Time.at(time).strftime("%H:%M - %d %b '%y")
  end

  def amount_s
    "%.6f" % amount
  end
end
