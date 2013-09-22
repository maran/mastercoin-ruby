require 'mastercoin-ruby'

describe Mastercoin::SimpleSend do
  before do 
    @simple_send = Mastercoin::SimpleSend.new(currency_id: 2, amount: 50, receiving_address: "184mQaxRYwiU2jqUE852FZGQvbZyRhcDSu")
  end

  context "Encoding and decoding addresses" do
    it "Should output a valid looking bitcoin address" do
      address = @simple_send.encode_to_address
      address.should eq("17vrMab8gQx72eCEaUxJzL4fg5VwEUumJQ") 
    end

    it "Should decode a valid looking bitcoin address" do
      simple_send = Mastercoin::SimpleSend.decode_from_address("17vrMab8gQx72eCEaUxJzL4fg5VwEUumJQ")
      simple_send.currency_id.should eq(2)
      simple_send.amount.should eq(50)
      simple_send.transaction_type.to_s.should eq(Mastercoin::TRANSACTION_SIMPLE_SEND)
    end

    it "Should backwards compatible with existing transactions" do
      simple_send = Mastercoin::SimpleSend.decode_from_address("1CVE9Au1XEm3MkYxeAhUDVqWvaHrP98iUt")
      simple_send.amount.should eq(100 * 1e8)
      simple_send.sequence.should eq(126)
      simple_send.transaction_type.should eq(0)
    end

    it "Should be backwards compatible with sequences" do
      Mastercoin::SimpleSend.new.get_sequence("1CcJFxoEW5PUwesMVxGrq6kAPJ1TJsSVqq").should eq(126)
    end
  end

  context "Encoding and decoding public keys" do
    it "Should accept all options for a SimpleSend transaction" do
      @simple_send.currency_id.should eq(2)
      @simple_send.amount.should eq(50)
      @simple_send.receiving_address.should eq("184mQaxRYwiU2jqUE852FZGQvbZyRhcDSu")
      @simple_send.transaction_type.should eq(Mastercoin::TRANSACTION_SIMPLE_SEND)
    end

    it "Should output a valid looking compressed public key" do
      public_key = @simple_send.encode_to_compressed_public_key
      public_key.should eq("020100000000000000020000000000000032000000000000000000000000000000") 
    end

    it "Should be a valid ECDSA point" do
      public_key = @simple_send.encode_to_compressed_public_key
      Mastercoin::Util.valid_ecdsa_point?(public_key).should eq(true)
    end

    it "Should always start with 02 for compressed key" do
      public_key = @simple_send.encode_to_compressed_public_key
      public_key[0..1].should eq("02")
    end

    it "Should be able to parse a given public key" do
      simple_send = Mastercoin::SimpleSend.decode_from_compressed_public_key("02000000000000000002000000000000003200000000000000000000000000000")
      simple_send.currency_id.should eq(2)
      simple_send.amount.should eq(50)
      simple_send.transaction_type.should eq(Mastercoin::TRANSACTION_SIMPLE_SEND)
      simple_send.public_key_sequence.should eq(1)
    end
  end
end
