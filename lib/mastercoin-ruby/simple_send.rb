module Mastercoin
  class SimpleSend < Mastercoin::Message
    attr_accessor :transaction_type, :currency_id, :amount, :receiving_address, :sequence 

    # Supply the amount in 'dacoinminster's
    def initialize(options= {})
      self.transaction_type = Mastercoin::TRANSACTION_SIMPLE_SEND
      self.currency_id = options[:currency_id]
      self.amount = options[:amount]
      self.receiving_address = options[:receiving_address]
    end

    # hardcode the sequence for a public key simple send since it's always fits inside a public key
    # Please note that we start at 01 - 00 will generate unvalid ECDSA points somehow
    def public_key_sequence
      01
    end

    def self.decode_key_to_data(public_key)
      simple_send = SimpleSend.new
      simple_send.transaction_type = public_key[2..9]#Mastercoin::TRANSACTION_SIMPLE_SEND
      simple_send.currency_id = public_key[10..17].to_i(16)
      simple_send.amount = public_key[18..33].to_i(16)
      simple_send.sequence = public_key[0..1].to_i(16)
      return simple_send
    end

    def encode_data_to_key
      raw = (self.public_key_sequence.to_i.to_s(16).rjust(2, "0") + self.transaction_type.to_i.to_s(16).rjust(8,"0") + self.currency_id.to_i.to_s(16).rjust(8, "0") + self.amount.to_i.to_s(16).rjust(16, "0"))
      raw = raw.ljust(62,"0")
      return raw
    end

    def encode_to_address
      raw = (self.get_sequence.to_i.to_s(16).rjust(2, "0") + self.transaction_type.to_i.to_s(16).rjust(8,"0") + self.currency_id.to_i.to_s(16).rjust(8, "0") + self.amount.to_i.to_s(16).rjust(16, "0") + "000000")
      Bitcoin.hash160_to_address(raw)
    end

    def self.decode_from_address(raw_address)
      simple_send = Mastercoin::SimpleSend.new
      decoded = Bitcoin.decode_base58(raw_address)
      simple_send.sequence = decoded[2..3].to_i(16)
      simple_send.transaction_type = decoded[4..11].to_i(16)
      simple_send.currency_id = decoded[12..19].to_i(16)
      simple_send.amount = decoded[20..35].to_i(16)
      return simple_send
    end

    def get_sequence(bitcoin_address = nil)
      bitcoin_address ||= self.receiving_address
      Mastercoin::Util.get_sequence(bitcoin_address)
    end

    def looks_like_mastercoin?
      Mastercoin::TRANSACTION_TYPES.keys.include?(self.transaction_type.to_i.to_s) && Mastercoin::CURRENCY_IDS.keys.include?(self.currency_id.to_s)
    end

    def explain(sending_address = nil)
      "SimpleSend transaction from #{sending_address} for %.8f #{self.currency_id_text} to #{self.receiving_address}." % (self.amount / 1e8)
    end

    def currency_id_text
      Mastercoin::CURRENCY_IDS[self.currency_id.to_s]
    end
  end
end
