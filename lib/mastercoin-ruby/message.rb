module Mastercoin
  class Message
    # Try to decode the keys and grab the keys that have a logical sequence number
    def self.probe(keys, xor_target)
      Message.decode(keys, xor_target).find_all do |key|
        (1..keys.count).collect{|x| x.to_s.rjust(2,"0")}.to_a.include?(key[0..1])
      end
    end

    def self.probe_and_read(keys, xor_target)
      result = Message.probe(keys, xor_target)
      transaction_type = result.join[2..9].to_i(16)
    
      if transaction_type == Mastercoin::TRANSACTION_SELL_FOR_BITCOIN
        puts "Found Selling Offer"
        Mastercoin::SellingOffer.decode_from_compressed_public_key(keys, xor_target)
      elsif transaction_type.to_s == Mastercoin::TRANSACTION_SIMPLE_SEND.to_s
        puts "Found Simple Send"
        Mastercoin::SimpleSend.decode_from_compressed_public_key(keys, xor_target)
      end
    end

    def self.decode(keys, xor_target)
      if keys.is_a?(Array)
        i = 1
        key_data = keys.collect do |key|
          impose = Mastercoin::Util.multiple_hash(xor_target, i)[0..-3]
          i += 1
          key = key.each_char.to_a.drop(2).reverse.drop(2).reverse.join
          # We are losing a char here, no idea why, just add it in for good measure
          Mastercoin::Util.xor_pack_unpack_strings(impose, key)
        end
      else
        impose = Mastercoin::Util.multiple_hash(xor_target, 1)[0..-3]
        key = keys.each_char.to_a.drop(2).reverse.drop(2).reverse.join
        key_data = Mastercoin::Util.xor_pack_unpack_strings(impose, key)
      end
    end

    def self.decode_from_compressed_public_key(keys, xor_target)
      key_data = self.decode(keys, xor_target)
      self.decode_key_to_data(key_data)
    end

    def encode_to_compressed_public_key(xor_target)
      keys = self.encode_data_to_key

      if keys.is_a?(String)
        impose = Mastercoin::Util.multiple_hash(xor_target, 1)[0..-3]
        new_key = "02" + Mastercoin::Util.xor_pack_unpack_strings(impose, keys)+ "00"
        result = mangle_key_until_valid(new_key)
      elsif keys.is_a?(Array)
        i = 1
        result = keys.collect do |key|
          impose = Mastercoin::Util.multiple_hash(xor_target, i)[0..-3]
          i += 1
          new_key = "02" + Mastercoin::Util.xor_pack_unpack_strings(impose, key)+ "00"

          mangle_key_until_valid(new_key)
        end
      end
      result
    end


    def mangle_key_until_valid(key)
      key[64..66] = Random.rand(256).to_s(16).rjust(2,"0")

      if Mastercoin::Util.valid_ecdsa_point?(key)
        return key
      else
        mangle_key_until_valid(key)
      end
    end
  end
end
