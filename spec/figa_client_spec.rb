
#
# Specifying figa
#
# Thu Jun 13 16:16:38 JST 2019
#

require 'spec_helper'


describe Figa::Client do

  describe '#map' do

    it 'returns mappings'
  end

  describe '#search' do

    it 'searches' do

      c = Figa::Client.new

      r = c.search('ibm')

      expect(r.class).to eq(Hash)
      expect(r.keys).to eq(%w[ data next _elapsed ])
      expect(r['data'].first['name']).to eq('Ibm')
    end

    it 'searches (advanced)' do

      c = Figa::Client.new

      r = c.search(query: 'ibm')

      expect(r.class).to eq(Hash)
      expect(r.keys).to eq(%w[ data next _elapsed ])
      expect(r['data'].first['name']).to eq('Ibm')
    end
  end
end

