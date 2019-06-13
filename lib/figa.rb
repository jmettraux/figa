
require 'json'
require 'net/http'


module Figa

  VERSION = '0.0.1'

  USER_AGENT = "Figa - https://github.com/jmettraux/figa - #{VERSION}"
  API_ROOT_URI = 'https://api.openfigi.com/v2'

  class Client

    def initialize(api_key=nil)

      @api_key = api_key
      @enum_values = {}
    end

    def map(h)

      k0 = h.is_a?(Hash) ? h.keys.first.to_s : nil

      if k0 && h.size == 1 && enum_values('idType').include?(k0)

        h = { idType: h.keys.first, idValue: h.values.first }
      end

      validate(h)

      fail ArgumentError.new("parameter 'idType' is missing"
        ) unless h[:idType] || h['idType']
      fail ArgumentError.new("parameter 'idValue' is missing"
        ) unless h[:idValue] || h['idValue']

      post('/mapping', h)
    end

    def search(h)

      h = { query: h } unless h.is_a?(Hash)

      validate(h)

      fail ArgumentError.new("parameter 'query' is missing"
        ) unless h[:query] || h['query']

      post('/search', h)
    end

    protected

    ENUM_KEYS = %w[
      idType exchCode micCode currency marketSecDes securityType securityType2 ]

    def list_enum_values(key)

      #fail ArgumentError.new(
      #  "key #{key.inspect} not included in #{KEYS.inspect}"
      #) unless KEYS.include?(key)

      get('/mapping/values/' + key)
    end

    def enum_values(key)

      @enum_values[key] ||= list_enum_values(key)
    end

    def validate(h)

      h.each do |k, v|

        sk = k.to_s
        next unless ENUM_KEYS.include?(sk)

        vs = (@enum_values[sk] ||= list_enum_values(key))

        fail ArgumentError.new(
          "value #{v.inspect} is not a valid value for key #{k.inspect}"
        ) unless enum_values(keys).include?(v)
      end
    end

    def get(uri); request(:get, uri); end
    def post(uri, data); request(:post, uri, data); end

    def request(method, uri, data=nil)

      uri = API_ROOT_URI + uri

      req = (method == :post ? Net::HTTP::Post : Net::HTTP::Get).new(uri)
      req.instance_eval { @header.clear }
      def req.set_header(k, v); @header[k] = [ v ]; end

      if data
        req.body = JSON.dump(data)
        req.content_type = 'application/json'
      end

      req.set_header('User-Agent', USER_AGENT)
      req.set_header('Accept', 'application/json')
# TODO api key

      u = URI(uri)

      t0 = monow

      t = Net::HTTP.new(u.host, u.port)
      t.use_ssl = (u.scheme == 'https')
#t.set_debug_output($stdout)
#t.set_debug_output($stdout) if u.to_s.match(/search/)

      res = t.request(req)

      #class << res; attr_accessor :_elapsed; end
      #res._elapsed = monow - t0

      j = JSON.parse(res.body)
      def j._response; res; end
      j['_elapsed'] = monow - t0
# TODO j['next']

      j
    end

    def monow; Process.clock_gettime(Process::CLOCK_MONOTONIC); end
  end
end

