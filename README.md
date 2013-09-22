# mastercoin-ruby

Mastercoin-ruby is a ruby library for Mastercoin. 

## Currently implemented

* Simple Send encoding to public keys
* Simple Send encoding to Bitcoin addresses
* Advise on creating a Address based transaction
* Lookup Exodus payments based on address or transaction

## Example usage

### Decoding a address
> $ simple_send decode_from_address 1CVE9Au1XEm3MkYxeAhUDVqWvaHrP98iUt

> $ SimpleSend transaction for 100.00000000 Mastercoin.

### Decoding a public key

> $ simple_send decode_from_public_key "02000000000000000002000000000000000100000000000000000000000000000" 

> $ SimpleSend transaction for 0.00000001 Test Mastercoin.

### Encoding to address

> $ simple_send encode_to_address --amount=100000000 --currency-id=2 --receiving_address=1CcJFxoEW5PUwesMVxGrq6kAPJ1TJsSVqq 

> $ 1CVE9Au1XEm3MsiMuLZpzvZinf4Fgu7aeA

### Advise for Simple Send

> $ simple_send advise --amount=100000000 --currency-id=2 --receiving_address=1CcJFxoEW5PUwesMVxGrq6kAPJ1TJsSVqq 

> $ Step 1: Send all funds in your wallet to the address which owns the MasterCoins (the following sends must come from that address)
Step 2: Send exactly 0.00006 BTC from your address to each of the following 3 addresses in one transaction:
The Exodus Address:    1EXoDusjGwvnjZUyKkxZ4UHEf77z6A5S4P
The recipient address: 1CcJFxoEW5PUwesMVxGrq6kAPJ1TJsSVqq
The data address:      1CVE9Au1XEm3MsiMuLZpzvZinf4Fgu7aeA

*Please note: The following commands will need a connection to an up-to-date bitcoin-ruby node since they need to traverse the network for Mastercoin data.*

### Checking how many coins a certain transaction to Exodus bought

> $ exodus_payment from_transaction 4c097244046e1b1fa23edc7ad8efd10babbe7c0caa13925c33097b84dae57af7 --storage="postgres://username:password@ip/database"

> $ Bought 1100.0 Mastercoins and got a 0 Mastercoins extra.

### Checking total Exodus payment for a given address

> $ exodus_payment from_address 1HRE7U9XNPD8kJBCwm5Q1VAepz25GBXnVk --storage="postgres://username:password@ip/database"

> $ Bought 1945.780909 Mastercoins and got a 2.05452329 Mastercoins extra.

## Contributing to mastercoin-ruby
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 Maran. See LICENSE.txt for
further details.

