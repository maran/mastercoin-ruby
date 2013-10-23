require 'mastercoin-ruby'

describe Mastercoin::SellingOffer do

  context "Encoding and decoding public keys" do
    before do
      @selling_offer = Mastercoin::SellingOffer.new(currency_id: 2, amount: 1e8.to_i, bitcoin_amount: 1e6.to_i, time_limit: 6, transaction_fee: 1e5.to_i)
    end

    it "Should encode to exactly two public keys" do
      keys = @selling_offer.encode_to_compressed_public_key("1J2svn2GxYx9LPrpCLFikmzn9kkrXBrk8B")
      keys.count.should eq(2)
    end

    it "Should encode valid public keys" do
      keys = @selling_offer.encode_to_compressed_public_key("1J2svn2GxYx9LPrpCLFikmzn9kkrXBrk8B")
      keys.first[0..-3].should eq("02d52c390e46f1110410078a9db14d124206924666fb10a5e8dbf9cc2e2ecde3")
      keys.last[0..-3].should eq("026c17b960d1aa810b6f736760a03166dec0ecc617de661915e06981d5d88f28")
      Mastercoin::Util.valid_ecdsa_point?(keys.first).should eq(true)
      Mastercoin::Util.valid_ecdsa_point?(keys.last).should eq(true)
    end

    it "Should decode public keys into a valid transaction" do
      keys = @selling_offer.encode_to_compressed_public_key("1J2svn2GxYx9LPrpCLFikmzn9kkrXBrk8B")
      offer_two = Mastercoin::SellingOffer.decode_from_compressed_public_key(keys, "1J2svn2GxYx9LPrpCLFikmzn9kkrXBrk8B")
      offer_two.amount.should eq(@selling_offer.amount)
      offer_two.bitcoin_amount.should eq(@selling_offer.bitcoin_amount)
      offer_two.currency_id.should eq(@selling_offer.currency_id)
      offer_two.transaction_fee.should eq(@selling_offer.transaction_fee)
      offer_two.time_limit.should eq(@selling_offer.time_limit)
    end

    it "Should strip sequence and compressed key format" do
      key = "0300000014000000020000000005f5e10000000000000f424060000000000018"
      Mastercoin::Util.strip_key(key).should eq("00000014000000020000000005f5e10000000000000f424060000000000018")
    end

    it "Should sort keys based on sequence number" do 
      keys = ["0300000014000000020000000005f5e10000000000000f424060000000000018","0200000014000000020000000005f5e10000000000000f424060000000000018", "0100000014000000020000000005f5e10000000000000f424060000000000018"]
      Mastercoin::Util.sort_keys(keys).should eq(["0100000014000000020000000005f5e10000000000000f424060000000000018",
                                                  "0200000014000000020000000005f5e10000000000000f424060000000000018",
                                                   "0300000014000000020000000005f5e10000000000000f424060000000000018"])
    end
  end
end
