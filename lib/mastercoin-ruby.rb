require 'bitcoin'
require 'logger'

module Mastercoin
  autoload :SimpleSend, 'mastercoin-ruby/simple_send'

  TRANSACTION_SIMPLE_SEND = 0

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

  def self.set_storage(storage_string)
    @storage_string = storage_string
  end

  def self.storage
    Bitcoin.network ||= :bitcoin
    @@storage ||= Bitcoin::Storage.sequel(:db => @storage_string)
    return @@storage
  end

  def self.init_logger(level = Logger::DEBUG)
    @@log ||= Logger.new(STDOUT)
    @@log.level = level
    @@log
  end

  def self.log
    @@log ||= Logger.new(STDOUT)
  end
end
