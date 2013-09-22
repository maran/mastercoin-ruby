module Mastercoin
  class ExodusPayment
    class TransactionNotFoundException < StandardError;end

    attr_accessor :coins_bought, :bonus_bought, :address, :tx, :time_included

    def to_s
      "Bought #{self.coins_bought} Mastercoins and got a #{self.bonus_bought} Mastercoins extra."
    end

    def to_json
      {coins_bought: self.coins_bought, bonus_bought: self.bonus_bought}.to_json
    end

    def total_amount
      self.coins_bought + self.bonus_bought
    end

    def self.from_transaction(hash) 
      buying = ExodusPayment.new
      buying.coins_bought = 0
      buying.bonus_bought = 0

      store = Mastercoin.storage
      tx = store.get_tx(hash)
      raise TransactionNotFoundException.new("Could not find the given transaction with #{hash}. Perhaps your blockchain is not up-to-date?") unless tx
      buying.tx = tx
      block_time = store.get_block_by_tx(tx.hash).time
      buying.time_included = block_time
      highest = ExodusPayment.highest_output_for_tx(tx)
      buying.address = highest

      exodus_output = tx.outputs.find{|x| x.to_hash(with_address:true)["address"] == Mastercoin::EXODUS_ADDRESS}

      if tx.get_block.depth <= Mastercoin::END_BLOCK
        btc_amount = (exodus_output.value / 1e8)
        bought =  btc_amount * 100
        buying.coins_bought += bought
        date_difference = (Mastercoin::END_TIME.to_i - block_time.to_i) / 60.0 / 60 / 24 / 7
        if date_difference > 0
          bonus = (btc_amount * 100 * (date_difference * 0.1))

          buying.bonus_bought += sprintf("%0.08f", bonus).to_f
        end
      end
      return buying
    end

    def self.highest_output_for_tx(tx)
      result = {}
      output_hash = tx.in.collect{|x| x.get_prev_out.to_hash(with_address: true) }

      output_hash.each do |output|
        address = output['address']
        result[address] ||= 0
        result[address] += output['value'].to_f
      end

      highest_input = result.sort{|x,y| y[1] <=> x[1]}
      highest_input = highest_input[0][0]
    end
    
    # This is a very slow and probably very inefficient way to calculate the coins bought
    # TODO: Please rewrite
    def self.from_address(address)
      buying = ExodusPayment.new
      @used = {}
      @rejected_tx = []

      buying.address = address

      buying.coins_bought = 0
      buying.bonus_bought = 0

      store = Mastercoin.storage
      txouts = store.get_txouts_for_address(address)

      # 1. Get all outputs for an address
      # 2. Check to see if this ouput has a next input for the Exodus address
      #    A. Get the tx for the next input if any exist
      #    B. Check if the tx has any outputs with the Exodus address
      # 3. If so find which input did the total best payments to Exodus
      # 4. Check the inputs for Exodus output and award the one with the highest total

      txouts.each do |txout|
        Mastercoin.log.debug("Checking txout: #{txout.to_hash(with_address: true)}")
        input = txout.get_next_in

        if input
          tx = input.get_tx
          next if @rejected_tx.include?(tx.hash)

          block_time = store.get_block_by_tx(tx.hash).time

          if tx.get_block.depth > Mastercoin::END_BLOCK
            Mastercoin.log.debug("Transaction after end date: Rejecting")
            @rejected_tx << tx.hash
            next
          end

          addresses = tx.outputs.collect{|x| x.to_hash(with_address: true)["address"] }

          unless addresses.include?(Mastercoin::EXODUS_ADDRESS)
            Mastercoin.log.debug("TX #{tx.hash} does not include transaction to Exodus")
            @rejected_tx << tx.hash
            next
          else
            Mastercoin.log.debug("TX #{tx.hash} is a transaction to Exodus")
          end

          highest_input = ExodusPayment.highest_output_for_tx(tx)

          Mastercoin.log.debug("Highest input for #{tx.hash} is #{highest_input}")

          # Get all the inputs from this transaction and see which has the higest one. the Funds belong to the input with the highest value
          tx.out.each do |output|
            if output.get_addresses.flatten.include?(Mastercoin::EXODUS_ADDRESS) && !@used.keys.include?(tx.hash)
              Mastercoin.log.debug("TX #{tx.hash} is not inside our used tx hash: #{@used.keys}")

              unless txout.get_address == highest_input
                Mastercoin.log.debug("This is not the highest input; can't give the coins. #{txout.get_address} we needed #{highest_input}")
                next
              else
              end

              @used[tx.hash] = highest_input

              btc_amount = (output.value / 1e8)
              bought = btc_amount * 100
              buying.coins_bought += bought
              date_difference = (Mastercoin::END_TIME.to_i - block_time.to_i) / 60.0 / 60 / 24 / 7
              if date_difference > 0
                bonus = (btc_amount * 100 * (date_difference * 0.1))

                buying.bonus_bought += sprintf("%0.08f", bonus).to_f
              end
            else
              Mastercoin.log.debug("This is not the Exodus output; probably change address")
            end
          end
        end
      end
      return buying
    end
  end
end

