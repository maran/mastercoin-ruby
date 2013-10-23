module Mastercoin
  class Util
    def self.sort_keys(public_keys)
      public_keys.sort{|x,y| x[0..1] <=> y[0..1]}
    end

    def self.strip_key(key)
      return key[2..-1]
    end

    def self.sort_and_strip_keys(keys)
      Util.sort_keys(keys).collect{|key| Util.strip_key(key)}
    end

    def self.multiple_hash(target, times = 1)
      times -= 1
      new_target = Digest::SHA256.hexdigest(target)[0..61]
      if times > 0 
        return multiple_hash(new_target)
      end

      return new_target
    end

    def self.valid_ecdsa_point?(pub_key)
      begin
        Bitcoin::Key.new(nil, pub_key).addr
      rescue OpenSSL::PKey::EC::Point::Error
        return false
      end

      return true
    end

    def self.get_sequence(bitcoin_address)
      decoded = Bitcoin.decode_base58(bitcoin_address)

      seq = decoded[2..3].to_i(16) - 1
      if seq < 0
        seq += 256
      end

      return seq
    end
  end
end
