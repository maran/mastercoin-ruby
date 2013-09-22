module Mastercoin
  class Transaction
    class NoMastercoinTransactionException < StandardError;end;

    attr_accessor :btc_tx
    attr_accessor :transaction_type, :currency_id, :amount
    attr_accessor :source_address
    attr_accessor :data_addresses, :rejected_outputs, :target_address

    def initialize(tx_hash)
      @store = Mastercoin.storage
      self.data_addresses = []
      self.rejected_outputs = [] 
      self.btc_tx = @store.get_tx(tx_hash)

      raise TransactionNotFoundException.new("Transaction #{tx_hash} could not be found. Is your blockchain up to date?") if self.btc_tx.nil?

#      if self.btc_tx.outputs.collect{|x| Bitcoin::Script.new(x.script).is_multisig? }.include?(true)
#        raise 'This is a multisig transaction, not supported yet'
#      end

      unless self.has_genesis_as_output?
        raise NoMastercoinTransaction.new("This transaction does not contain a txout to the genesis address, invalid.")
      end

      unless self.has_three_outputs?
        raise NoMastercoinTransaction.new("This transaction does not contain three outputs, invalid.")
      end

      self.source_address = Mastercoin::ExodusPayment.highest_output_for_tx(self.btc_tx)

      self.btc_tx.outputs.each do |output|
        if output.get_address == Mastercoin::EXODUS_ADDRESS
          # Do nothing yet; this is simply the exodus address
        elsif Mastercoin::SimpleSend.decode_from_address(output.get_address).looks_like_mastercoin? # This looks like a data packet
          self.data_addresses << Mastercoin::SimpleSend.decode_from_address(output.get_address)
        end
      end

      self.data_addresses.sort!{|x, y| x.sequence.to_i <=> y.sequence.to_i }

      self.btc_tx.outputs.each do |output|
        address = output.get_address
        sequence = Mastercoin::Util.get_sequence(address)
        if self.data_addresses[0].sequence.to_s == sequence.to_s
          self.target_address = address
        end
      end

      self.analyze_addresses!
    end

    def analyze_addresses!
      address = self.data_addresses[0]
      self.transaction_type = address.transaction_type
      self.currency_id = address.currency_id
      self.amount = address.amount
    end

    def has_three_outputs?
      self.btc_tx.outputs.size >= 3
    end

    def has_genesis_as_output?
      self.btc_tx.outputs.collect{|x| x.get_address == Mastercoin::EXODUS_ADDRESS}.any?
    end

    def to_s
      if self.transaction_type == 0
        "Simple send:: Sent #{self.amount / 1e8} '#{Mastercoin::CURRENCY_IDS[self.currency_id.to_s]}' to #{self.target_address}"
      else
        "Unknown transaction"
      end
    end
  end
end
