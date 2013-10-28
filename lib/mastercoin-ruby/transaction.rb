module Mastercoin
  class Transaction
    class NoMastercoinTransactionException < StandardError;end;

    attr_accessor :btc_tx
    attr_accessor :transaction_type, :currency_id, :amount
    attr_accessor :source_address
    attr_accessor :data_addresses, :rejected_outputs, :target_address, :multisig, :sending_address

    attr_accessor :key_data

    def initialize(tx_hash)
      @store = Mastercoin.storage
      self.data_addresses = []
      self.rejected_outputs = [] 
      self.btc_tx = @store.get_tx(tx_hash)
      self.sending_address = btc_tx.inputs.first.get_prev_out.get_address
      exodus_value = nil

      raise TransactionNotFoundException.new("Transaction #{tx_hash} could not be found. Is your blockchain up to date?") if self.btc_tx.nil?

      unless self.has_genesis_as_output?
        raise NoMastercoinTransactionException.new("This transaction does not contain a txout to the genesis address, invalid.")
      end

      unless self.has_three_outputs?
        raise NoMastercoinTransactionException.new("This transaction does not contain three outputs, invalid.")
      end
 
      if self.btc_tx.outputs.collect{|x| x.script.is_multisig?}.include?(true)
        self.multisig = true
      else
        self.multisig = false
      end

      self.source_address = Mastercoin::ExodusPayment.highest_output_for_tx(self.btc_tx)

      if multisig
        self.btc_tx.outputs.each do |output|
          if output.get_address == Mastercoin::EXODUS_ADDRESS
            exodus_value = output.value
          end
        end

        self.btc_tx.outputs.each do |output|
          if output.script.is_multisig?
            keys = output.script.get_multisig_pubkeys.collect{|x| x.unpack("H*")[0]}
            self.key_data = Mastercoin::Message.probe_and_read(keys, self.sending_address)
          elsif output.get_address == Mastercoin::EXODUS_ADDRESS
            # Do nothing for now
          else
            self.target_address = output.get_address if output.value == exodus_value
          end
        end
      else
        self.btc_tx.outputs.each do |output|
          if output.get_address == Mastercoin::EXODUS_ADDRESS
            # Do nothing yet; this is simply the exodus address
          elsif Mastercoin::SimpleSend.decode_from_address(output.get_address).looks_like_mastercoin? # This looks like a data packet
            self.data_addresses << Mastercoin::SimpleSend.decode_from_address(output.get_address)
          end
        end

        self.btc_tx.outputs.each do |output|
          address = output.get_address
          sequence = Mastercoin::Util.get_sequence(address)

          if self.data_addresses[0].sequence.to_s == sequence.to_s
            self.target_address = address
          end
        end
        self.data_addresses.sort!{|x, y| x.sequence.to_i <=> y.sequence.to_i }
      end

      self.analyze_addresses!
      raise NoMastercoinTransactionException.new("Could not find a valid looking data-address, invalid.") unless self.data_addresses.any?
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
      if self.transaction_type.to_i.to_s == "0"
        "Simple send:: Sent #{self.amount / 1e8} '#{Mastercoin::CURRENCY_IDS[self.currency_id.to_s]}' to #{self.target_address}"
      elsif self.transaction_type.to_i.to_s == "20"
        "Selling offer:: Sent #{self.amount / 1e8} '#{Mastercoin::CURRENCY_IDS[self.currency_id.to_s]}' to #{self.target_address}"
      else
        "Unknown transaction: #{self.transaction_type}"
      end
    end
  end
end
