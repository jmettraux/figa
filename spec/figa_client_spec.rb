
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
  end

  describe '#search' do

    it 'searches' do

      r = @client.search('ibm')

      expect(r.class).to eq(Hash)
      expect(r.keys).to eq(%w[ data next ])
      expect(r._elapsed).to be > 0.0
      expect(r._client).to eq(@client)
      expect(r._response.class).to eq(Net::HTTPOK)
      expect(r['data'].first['name']).to eq('Ibm')
    end

    it 'searches (advanced)' do

      r = @client.search(query: 'ibm')

      expect(r.class).to eq(Hash)
      expect(r.keys).to eq(%w[ data next ])
      expect(r['data'].first['name']).to eq('Ibm')
    end
  end
end

