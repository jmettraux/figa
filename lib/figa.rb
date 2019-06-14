
require 'json'
require 'net/http'


module Figa

  VERSION = '0.1.0'

  USER_AGENT = "Figa - https://github.com/jmettraux/figa - #{VERSION}"
  API_ROOT_URI = 'https://api.openfigi.com/v2'

  class Client

    def initialize(api_key=nil)

      @api_key = api_key
      @enum_values = {}
    end

    def map(array_or_hash)

      a = to_mapping_parameter_array(array_or_hash)

      post('/mapping', a)
    end

    def search(q, h={})

      h = q.is_a?(String) ? h.merge(query: q) : q

      validate(h)

      fail ArgumentError.new("parameter 'query' is missing"
        ) unless h[:query] || h['query']

      post('/search', h)
    end

    protected

    def to_mapping_parameter_array(aoh)

      a = aoh.is_a?(Array) ? aoh : [ aoh ]

      id_types = enum_values('idType')

      a.collect do |h|

        oldk, itk =
          h.keys.inject(nil) { |r, k|
            next r if r
            kk = k.upcase; next [ k, kk ] if id_types.include?(kk)
            kk = "ID_#{kk}"; next [ k, kk ] if id_types.include?(kk)
            nil }
        if oldk
          h[:idType] = itk
          h[:idValue] = h.delete(oldk)
        end

        validate(h)

        fail ArgumentError.new("parameter 'idType' is missing"
          ) unless h[:idType] || h['idType']
        fail ArgumentError.new("parameter 'idValue' is missing"
          ) unless h[:idValue] || h['idValue']

        h
      end
    end

    ENUM_KEYS = %w[
      idType exchCode micCode currency marketSecDes securityType securityType2 ]

    def enum_values(key)

      @enum_values[key] ||= get('/mapping/values/' + key)['values']
    end

    def validate(h)

      fail ArgumentError.new("#{h.inspect} is not a Hash") unless h.is_a?(Hash)

      h.each do |k, v|

        sk = k.to_s
        next unless ENUM_KEYS.include?(sk)

        fail ArgumentError.new(
          "value #{v.inspect} is not a valid value for key #{k.inspect}"
        ) unless enum_values(sk).include?(v)
      end
    end

    def get(uri); request(:get, uri); end
    def post(uri, data); request(:post, uri, data); end

    def request(method, uri, data=nil)

      uri = API_ROOT_URI + uri unless uri.match(/\Ahttps:\/\//)

      req = (method == :post ? Net::HTTP::Post : Net::HTTP::Get).new(uri)
      req.instance_eval { @header.clear }
      def req.set_header(k, v); @header[k] = [ v ]; end

      if data
        req.body = JSON.dump(data)
        req.content_type = 'application/json'
      end

      req.set_header('User-Agent', USER_AGENT)
      req.set_header('Accept', 'application/json')
      req.set_header('X-OPENFIGI-APIKEY', @api_key) if @api_key

      u = URI(uri)

      t0 = monow

      t = Net::HTTP.new(u.host, u.port)
      t.use_ssl = (u.scheme == 'https')
#t.set_debug_output($stdout)
#t.set_debug_output($stdout) if uri.match(/search/)

      res = t.request(req)

      j = JSON.parse(res.body)
        #
      class << j
        attr_accessor :_response, :_client, :_elapsed, :_method, :_uri, :_form
      end
        #
      j._response = res
      j._client = self
      j._elapsed = monow - t0
      j._method = method
      j._uri = uri
      j._form = data
        #
      def j.next
        n = self['next']; return nil unless n && n.is_a?(String)
        _client.send(:request, _method, _uri, _form.merge(start: n))
      end if j.is_a?(Hash)

      j
    end

    def monow; Process.clock_gettime(Process::CLOCK_MONOTONIC); end
  end
end

