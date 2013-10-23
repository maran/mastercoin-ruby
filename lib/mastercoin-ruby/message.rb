module Mastercoin
  class Message
    def self.decode_from_compressed_public_key(keys, xor_target)
      if keys.is_a?(Array)
        i = 1
        key_data = keys.collect do |key|
          impose = Mastercoin::Util.multiple_hash(xor_target, i)
          i += 1
          key = key.each_char.to_a.drop(2).reverse.drop(2).reverse.join
          # We are losing a char here, no idea why, just add it in for good measure
          a = "0" +(key.to_i(16) ^ impose.to_i(16)).to_s(16)
          puts "ASD #{a}"
          a
        end
      else
        impose = Digest::SHA256.hexdigest(xor_target)[0..61]
        key = keys.each_char.to_a.drop(2).reverse.drop(2).reverse.join
        key_data = "0" +(key.to_i(16) ^ impose.to_i(16)).to_s(16)
      end
      self.decode_key_to_data(key_data)
    end

    def encode_to_compressed_public_key(xor_target)
      puts "XOR Reference: #{xor_target}"
      keys = self.encode_data_to_key

      if keys.is_a?(Array)
        puts "Clear text Mastercoin message: #{keys.join(', ')}"
      else
        puts "Clear text Mastercoin message: #{keys}"
      end

      if keys.is_a?(String)
        impose = Digest::SHA256.hexdigest(xor_target)[0..61]
        puts "SHA2 hash: #{impose}"
        new_key = "02" + (keys.to_i(16) ^ impose.to_i(16)).to_s(16) + "00"
        result = mangle_key_until_valid(new_key)
        puts "Result: #{result}"
      elsif keys.is_a?(Array)
        i = 1
        result = keys.collect do |key|
          puts "Hashing #{i} times"
          impose = Mastercoin::Util.multiple_hash(xor_target, i)
          i += 1
          puts "Using SHA2: #{impose}"
          new_key = "02" + (key.to_i(16) ^ impose.to_i(16)).to_s(16) + "00"
          mangle_key_until_valid(new_key)
        end

        puts "Result: #{result.join(', ')}"
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
