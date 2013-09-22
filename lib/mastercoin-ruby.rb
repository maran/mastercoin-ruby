require 'bitcoin'
require 'logger'

module Mastercoin
  class TransactionNotFoundException < StandardError;end
  autoload :SimpleSend, 'mastercoin-ruby/simple_send'
  autoload :ExodusPayment, 'mastercoin-ruby/exodus_payment'
  autoload :Transaction, 'mastercoin-ruby/transaction'
  autoload :Util, 'mastercoin-ruby/util'
  autoload :BitcoinWrapper, 'mastercoin-ruby/bitcoin_wrapper'

  TRANSACTION_SIMPLE_SEND = "0"

  TRANSACTION_TYPES = {
    TRANSACTION_SIMPLE_SEND => "Simple transfer",
    "10" => "Mark saving",
    "11" => "Mark compromised",
    "20" => "Currency trade offer bitcoins",
    "21" => "Currency trade offer master-coin derived",
    "22" => "Currency trade offer accept",
    "30" => "Register data-stream",
    "40" => "Bet offer",
    "100" => "Create child currency"
  }

  CURRENCY_IDS = {
    "1" => "Mastercoin",
    "2" => "Test Mastercoin"
  }

  EXODUS_ADDRESS = "1EXoDusjGwvnjZUyKkxZ4UHEf77z6A5S4P"
  END_TIME = Time.new(2013,9,01,00,00,00, "+00:00")
  END_BLOCK = 255365

  def self.set_storage(storage_string)
    @storage_string = storage_string
  end

  def self.storage
    Bitcoin.network ||= :bitcoin
    @@storage ||= Bitcoin::Storage.sequel(:db => @storage_string)
    return @@storage
  end

  def self.init_logger(level = Logger::INFO)
    @@log ||= Logger.new(STDOUT)
    @@log.level = level
    @@log
  end

  def self.log
    @@log ||= Mastercoin.init_logger
  end
end
