#!/usr/bin/env ruby
$:.unshift( File.expand_path("../../lib", __FILE__) )
require 'mastercoin-ruby'
require 'thor'
require 'bitcoin'
require 'json'
require 'io/console'
require 'pp'

module Mastercoin
  module Cli
    class Wallet < Thor
      include Bitcoin::Builder
      class_option :bitcoin_rpc, required: true

      desc "from_address <bitcoin_address>", "Calculates total amount of mastercoins bought"
      def build_transaction(from_address, to_address, amount)
        Bitcoin.network = :bitcoin

        w = Mastercoin::BitcoinWrapper.new(options[:bitcoin_rpc])
        puts "+----------------------------------+"
        puts "+ WARNING: ALPHA SOFTWARE          +"
        puts "+----------------------------------+"
        puts ""
        puts "This software might: "
        puts "1. Skin and eat your cat alive"
        puts "2. Eat your bitcoins"
        puts "3. Do other scary things you never intended" 
        puts "So for now please only use this if you can read enough code to understand what is happening." 
        puts ""
        puts "Please type: yup if you want to continue."

        STDOUT.flush  
        do_it = $stdin.gets
        unless do_it == "yup\n"
          puts "I don't blame you, exiting"
          exit
        end

        puts ""
        puts "This script requires the private key of your mastercoin address in order to create a signed transaction. It will need to unlock your wallet in order to do so."
        puts "Please type your wallet passphrase to unlock your wallet for 30 seconds."

        password = STDIN.noecho(&:gets)
        password = password.gsub("\n","")

        w.walletpassphrase(password, 30) 

        puts "Checking funds for address #{from_address}"
        inputs = w.unspend_for_address(from_address).find{|x| x["amount"].to_f > (0.00006 * 3)}
        unless inputs.any?
          puts("There are not enough bitcoin available to create a valid looking Mastercoin transaction. We want one output with enough funds for now.")
          exit
        else
          puts("Enough Bitcoin funds available") 
        end
        
        puts ">> Not checking for Mastercoin balance yet; assuming enough."
        puts "Getting private key and public key for Mastercoin address" 

        private_key = w.dumpprivkey(from_address)
        public_key = w.validateaddress(from_address)["pubkey"]
        
        if inputs.is_a?(Array)
          chosen_input = inputs.first
        else
          chosen_input = inputs
        end

        puts "Getting raw transaction data" 
        prev_tx = w.getrawtransaction(chosen_input["txid"])

        puts "Found raw transaction; unpacking into tx"
        prev_tx = Bitcoin::Protocol::Tx.new([prev_tx].pack("H*"))

        total_amount = chosen_input["amount"]
        fee = 0.0005
        tx_amount = 0.00006
        mastercoin_tx = (3 * tx_amount)
        change_amount = total_amount - fee - mastercoin_tx
        puts "Setting fees"

        data_key = Mastercoin::SimpleSend.new(currency_id: 2, amount: amount.to_f * 1e8).encode_to_compressed_public_key
        
        puts "Total amount available from input: #{total_amount}"
        puts "Paying #{fee} network fees"
        puts "Taking #{mastercoin_tx} out of total for each mastercoin output"
        puts "Sending #{change_amount} back to mastercoin address"
        puts "Using public key for data: #{data_key}"
        tx = build_tx do |t|
          t.input do |i|
            i.prev_out prev_tx
            i.prev_out_index chosen_input["vout"]
            i.signature_key Bitcoin::Key.from_base58(private_key)
          end

          # Change address
          t.output do |o|
            o.value change_amount * 1e8

            o.script do |s|
              s.type :address
              s.recipient from_address
            end
          end

          # Receiving address
          t.output do |o|
            o.value tx_amount * 1e8

            o.script do |s|
              s.type :address
              s.recipient to_address
            end
          end

          # Exodus address
          t.output do |o|
            o.value tx_amount * 1e8

            o.script do |s|
              s.type :address
              s.recipient Mastercoin::EXODUS_ADDRESS
            end
          end

          # Data address
          t.output do |o|
            o.value tx_amount * 1e8

            o.script do |s|
              s.type :multisig
              s.recipient 1, public_key, data_key
            end
          end
        end

        tx = Bitcoin::Protocol::Tx.new( tx.to_payload )
        puts "Need #{tx.calculate_minimum_fee / 1e8} fee-wise"
        valid = tx.verify_input_signature(0, prev_tx) == true
        multisig = Bitcoin::Script.new(tx.out.last.script).is_multisig?
        puts "Does this transaction look valid: #{valid}"
        puts "Is a valid multisig transaction: #{multisig}"

        puts "Transaction looks like: "
        pp tx.to_hash
        transaction_hash = tx.to_payload.unpack("H*").first
        puts "Raw hex encoded transaction for Bitcoind: "
        puts "-------------------------------------------------"
        puts transaction_hash
        puts "-------------------------------------------------"
        
        puts "Sending #{amount} Testnet Mastercoins to #{to_address}."
        puts "Want me to send this transaction via Bitcoind? [no]"
        STDOUT.flush  
        do_it = $stdin.gets
        if do_it == "yes\n"
          puts "Broadcasting transaction"
          w.sendrawtransaction(transaction_hash)
        else
          puts "Not broadcasting transaction"
        end
      end
    end
  end
end

Mastercoin::Cli::Wallet.start(ARGV)
