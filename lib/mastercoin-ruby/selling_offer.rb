module Mastercoin
  class SellingOffer < Mastercoin::Message
    class CannotDecodeSellingOfferException < StandardError;end

    attr_accessor :transaction_type, :currency_id, :amount, :bitcoin_amount, :time_limit, :transaction_fee

    def initialize(options = {})
      options.reverse_merge!({time_limit: 10, transaction_fee: 20000})
      self.transaction_type = Mastercoin::TRANSACTION_SELL_FOR_BITCOIN
      self.currency_id = options[:currency_id]
      self.amount = options[:amount]
      self.bitcoin_amount = options[:bitcoin_amount]
      self.time_limit = options[:time_limit]
      self.transaction_fee = options[:transaction_fee]
    end

    def self.decode_key_to_data(keys)
      raise CannotDecodeSellingOfferException.new("Need an array of two public keys in order to decode Selling Offer") unless keys.is_a?(Array) || keys.count != 2

      key = Mastercoin::Util.sort_and_strip_keys(keys).join
      
      offer = SellingOffer.new
      offer.transaction_type = key[0..7].to_i(16)
      offer.currency_id = key[8..15].to_i(16)
      offer.amount = key[16..31].to_i(16)
      offer.bitcoin_amount = key[32..47].to_i(16)
      offer.time_limit = key[48..49].to_i(16)
      offer.transaction_fee = key[50..65].to_i(16)
      offer
    end

    def encode_data_to_key
      raw = self.transaction_type.to_i.to_s(16).rjust(8,"0") + self.currency_id.to_i.to_s(16).rjust(8, "0") + self.amount.to_i.to_s(16).rjust(16, "0") + self.bitcoin_amount.to_i.to_s(16).rjust(16, "0") + self.time_limit.to_i.to_s(16).rjust(2,"0") + self.transaction_fee.to_i.to_s(16).rjust(16,"0")
      raw = raw.ljust(120,"0")
      keys = raw.chars.each_slice(60).map(&:join)
      keys.each_with_index.collect do |key, index|
        "#{(index + 1).to_s(16).rjust(2,"0")}#{key}"
      end
    end

    def explain
      "Selling Offer of #{(self.amount / 1e8).to_f} #{Mastercoin::CURRENCY_IDS[self.currency_id.to_s]} for #{(self.bitcoin_amount / 1e8).to_f} Bitcoins. Time limit #{self.time_limit}. BTC Fee #{self.transaction_fee}"
    end
  end
end
