# mastercoin-ruby

Mastercoin-ruby is a ruby library for Mastercoin. 

## Currently implemented

* Simple Send encoding to public keys
* Simple Send encoding to Bitcoin addresses

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

