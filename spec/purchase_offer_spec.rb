require 'mastercoin-ruby'

describe Mastercoin::PurchaseOffer do
  before do 
    @purchase_offer = Mastercoin::PurchaseOffer.new(currency_id: 2, amount: 50)
  end

  it "Should generate valid non-obfusciated Mastercoin keys" do
    @purchase_offer.encode_data_to_key.should eq("01000000000000000200000000000000320000000000000000000000000000")
  end

  it "Should parse valid non-obfusciated keys" do
    @purchase_offer = Mastercoin::PurchaseOffer.decode_key_to_data("01000000000000000200000000000000320000000000000000000000000000")
    @purchase_offer.currency_id.should be(2)
    @purchase_offer.amount.should be(50)
  end

  it "Should generate valid obfusciated Mastercoin keys" do
    @purchase_offer.encode_to_compressed_public_key("1J2svn2GxYx9LPrpCLFikmzn9kkrXBrk8B")[0..-3].should eq("02d52c390e52f1110410078a9db148e7a334924666fb10aaaa9bffcc2e2ecde3")
  end

  it "Should read valid obfusciated Mastercoin keys" do
    @purchase_offer = Mastercoin::PurchaseOffer.decode_from_compressed_public_key("02d52c390e52f1110410078a9db148e7a334924666fb10aaaa9bffcc2e2ecde311", "1J2svn2GxYx9LPrpCLFikmzn9kkrXBrk8B")
    @purchase_offer.currency_id.should be(2)
    @purchase_offer.amount.should be(50)
  end
end
