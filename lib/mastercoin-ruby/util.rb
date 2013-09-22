module Mastercoin
  class Util
    def self.get_sequence(bitcoin_address)
      decoded = Bitcoin.decode_base58(bitcoin_address)

      seq = decoded[2..3].to_i(16) - 1
      if seq > 255
        seq -= 255
      end

      return seq
    end
  end
end
