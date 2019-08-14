
#
# Specifying figa
#
# Thu Jun 13 16:16:38 JST 2019
#

require 'spec_helper'


describe Figa::Client do

  before :each do

    k = File.read('.api.key').strip rescue nil
    @client = Figa::Client.new(k)
  end

  describe '#map' do

    it 'returns mappings' do

      r = @client.map(isin: 'US4592001014')

      expect(r.class).to eq(Array)
      expect(r.size).to eq(1)
      expect(r[0]['data'].size).to be > 1
      expect(r[0]['data'][0]['name']).to eq('INTL BUSINESS MACHINES CORP')
    end

    it 'queries with more parameters' do

      r = @client.map(isin: 'US4592001014', exchCode: 'US')

      expect(r.class).to eq(Array)
      expect(r.size).to eq(1)
      expect(r[0]['data'].size).to eq(1)
      expect(r[0]['data'][0]['figi']).to eq('BBG000BLNNH6')
      expect(r[0]['data'][0]['name']).to eq('INTL BUSINESS MACHINES CORP')
    end

    it 'queries for multiple items' do

      r = @client.map([
        { isin: 'US4592001014' },
        { idType: 'ID_WERTPAPIER', idValue: '851399', exchCode: 'US' } ])

      expect(r.class).to eq(Array)
      expect(r.size).to eq(2)
      expect(r[0]['data'].size).to be > 1
      expect(r[0]['data'][0]['name']).to eq('INTL BUSINESS MACHINES CORP')
      expect(r[0]['data'][0]['ticker']).to eq('IBM')
      expect(r[1]['data'].size).to eq(1)
      expect(r[1]['data'][0]['name']).to eq('INTL BUSINESS MACHINES CORP')
      expect(r[1]['data'][0]['ticker']).to eq('IBM')
    end
  end

  describe '#enum_values' do

    it 'returns a map key -> values' do

      expect(
        @client.enum_values.keys.sort
      ).to eq(
        Figa::Client::ENUM_KEYS.sort
      )
    end
  end

  describe '#search' do

    it 'searches (s)' do

      r = @client.search('ibm')

      expect(r.class).to eq(Hash)
      expect(r.keys).to eq(%w[ data next ])
      expect(r._elapsed).to be > 0.0
      expect(r._client).to eq(@client)
      expect(r._response.class).to eq(Net::HTTPOK)
      expect(r['data'].first['name']).to eq('Ibm')
    end

    it 'searches (h)' do

      r = @client.search(query: 'ibm')

      expect(r.class).to eq(Hash)
      expect(r.keys).to eq(%w[ data next ])
      expect(r['data'].first['name']).to eq('Ibm')
    end

    it 'searches (h)' do

      r = @client.search('query' => 'ibm')

      expect(r.class).to eq(Hash)
      expect(r.keys).to eq(%w[ data next ])
      expect(r['data'].first['name']).to eq('Ibm')
    end

    it 'searches (h+)' do

      r = @client.search(query: 'ibm', exchCode: 'US')

      expect(r.class).to eq(Hash)
      expect(r.keys).to eq(%w[ data next ])
      expect(r['data'].first['name']).to eq('INTL BUSINESS MACHINES CORP')
    end

    it 'searches (s + h)' do

      r = @client.search('ibm', exchCode: 'US')

      expect(r.class).to eq(Hash)
      expect(r.keys).to eq(%w[ data next ])
      expect(r['data'].first['name']).to eq('INTL BUSINESS MACHINES CORP')
    end

    it 'iterates the search thanks to #next' do

      r = @client.search(query: 'ibm')

      expect(r['data'].first['figi']).to match(/\ABBG00[A-Z0-9]{7}\z/)
      expect(r['data'].first['ticker']).to match(/IBM/)

      figi0 = r['data'].first['figi']
      ticker0 = r['data'].first['ticker']

      r = r.next

      expect(r['data'].first['figi']).not_to eq(figi0)
      expect(r['data'].first['ticker']).not_to eq(ticker0)

      expect(r['data'].first['figi']).to match(/\ABBG00[A-Z0-9]{7}\z/)
      expect(r['data'].first['ticker']).to match(/IBM/)

#pp @client.search(query: 'UOL', securityType2: 'Common Stock', exchCode: 'SP')
#pp @client.search(query: 'UOL', exchCode: 'SP')
    end
  end
end

