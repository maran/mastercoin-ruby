module Mastercoin
  class Util
    def self.sort_keys(public_keys)
      public_keys.sort{|x,y| x[2..3] <=> y[2..3]}
    end

    def self.strip_key(key)
      return key[4..-1]
    end

    def self.sort_and_strip_keys(keys)
      Util.sort_keys(keys).collect{|key| Util.strip_key(key)}
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
      if seq > 255
        seq -= 255
      end

      return seq.abs
    end
  end
end
