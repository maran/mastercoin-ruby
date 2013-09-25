# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mastercoin-ruby"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Maran"]
  s.date = "2013-09-25"
  s.description = "Basic implementation of the Mastercoin protocol."
  s.email = "maran.hidskes@gmail.com"
  s.executables = ["exodus_payment", "mastercoin_transaction", "simple_send", "wallet.rb"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/exodus_payment",
    "bin/mastercoin_transaction",
    "bin/simple_send",
    "bin/wallet.rb",
    "lib/mastercoin-ruby.rb",
    "lib/mastercoin-ruby/bitcoin_wrapper.rb",
    "lib/mastercoin-ruby/exodus_payment.rb",
    "lib/mastercoin-ruby/simple_send.rb",
    "lib/mastercoin-ruby/transaction.rb",
    "lib/mastercoin-ruby/util.rb",
    "mastercoin-ruby.gemspec",
    "spec/simple_send.rb"
  ]
  s.homepage = "http://github.com/maran/mastercoin-ruby"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Ruby library for the Mastercoin protocol"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bitcoin-ruby>, ["~> 0.0.1"])
      s.add_runtime_dependency(%q<sequel>, ["~> 4.1.1"])
      s.add_runtime_dependency(%q<thor>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<bitcoin-ruby>, ["~> 0.0.1"])
      s.add_dependency(%q<sequel>, ["~> 4.1.1"])
      s.add_dependency(%q<thor>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<bitcoin-ruby>, ["~> 0.0.1"])
    s.add_dependency(%q<sequel>, ["~> 4.1.1"])
    s.add_dependency(%q<thor>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

