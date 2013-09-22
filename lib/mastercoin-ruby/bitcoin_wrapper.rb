# *-* encoding: utf-8 *-*
require 'net/http'
require 'uri'
require 'json'
require 'yaml'
module Mastercoin
  class BitcoinWrapper
    # also see: https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_Calls_list
    def initialize(service_url)
      @uri = URI.parse(service_url)
    end

    def unspend_for_address(address)
      unspend = self.listunspent.find{|x| x["address"] == address}
      if unspend.is_a?(Array)
       return unspend
      else
        return [unspend]
      end
    end

    def method_missing(name, *args)
      post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
      resp = JSON.parse( http_post_request(post_body) )

      raise JSONRPCError, resp['error'] if resp['error']

      resp['result']
    end

    def http_post_request(post_body)
      http    = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Post.new(@uri.request_uri)

      request.basic_auth @uri.user, @uri.password
      request.content_type = 'application/json'
      request.body = post_body

      http.request(request).body
    end

    class JSONRPCError < RuntimeError; end
  end
end
