module Mastercoin
  class Message
    def self.decode_from_compressed_public_key(keys, xor_target)
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
