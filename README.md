
# figa

[![Gem Version](https://badge.fury.io/rb/figa.svg)](http://badge.fury.io/rb/figa)

A Ruby library to query [OpenFIGI](https://www.openfigi.com/) API [v2](https://www.openfigi.com/api#v2).


## usage

Instantiate a Figa client:
```ruby
client = Figa::Client.new
  #
  # instantiate a client without API key

client = Figa::Client.new('321456cd-af64-9932-bcbe-1a2345677999')
  #
  # instantiate a client with an API key
```

Query for mappings ([/v2/mapping](https://www.openfigi.com/api#post-v2-mapping)):
```ruby
client = Figa::Client.new

r = client.map(isin: 'US4592001014')

pp r
  # ==>
  # [{"data"=>
  #  [{"figi"=>"BBG000BLNNH6",
  #    "name"=>"INTL BUSINESS MACHINES CORP",
  #    "ticker"=>"IBM",
  #    "exchCode"=>"US",
  #    "compositeFIGI"=>"BBG000BLNNH6",
  #    "uniqueID"=>"EQ0010080100001000",
  #    "securityType"=>"Common Stock",
  #    "marketSector"=>"Equity",
  #    "shareClassFIGI"=>"BBG001S5S399",
  #    "uniqueIDFutOpt"=>nil,
  #    "securityType2"=>"Common Stock",
  #    "securityDescription"=>"IBM"},
  #   {"figi"=>"BBG000BLNNV0",
  #    "name"=>"INTL BUSINESS MACHINES CORP",
  #    "ticker"=>"IBM",
  #    "exchCode"=>"UA",
  #    "compositeFIGI"=>"BBG000BLNNH6",
  #    "uniqueID"=>"EQ0010080100001000",
  #    "securityType"=>"Common Stock",
  #    "marketSector"=>"Equity",
  #    "shareClassFIGI"=>"BBG001S5S399",
  #    "uniqueIDFutOpt"=>nil,
  #    "securityType2"=>"Common Stock",
  #    "securityDescription"=>"IBM"},
  #   ...

r = client.map(isin: 'US4592001014', exchCode: 'US')
r = client.map(idType: 'ID_ISIN', idValue: 'US4592001014', exchCode: 'US')

# one can query for multiple items
r = client.map([
  { isin: 'US4592001014' },
  { idType: 'ID_WERTPAPIER', idValue: '851399', exchCode: 'US' } ])
```

Query for search ([/v2/search](https://www.openfigi.com/api#post-v2-search)):
```ruby
r = client.search('ibm')
r = client.search(query: 'ibm')
r = client.search('ibm', exchCode: 'US')
r = client.search(query: 'ibm', exchCode: 'US')

pp r
  # ==>
  # {"data"=>
  #   [{"figi"=>"BBG00196W5Z9",
  #     "name"=>"Ibm",
  #     "ticker"=>"IBMD=4",
  #     "exchCode"=>"OC",
  #     "compositeFIGI"=>nil,
  #     "uniqueID"=>"EF12901854300074186897",
  #     "securityType"=>"DIVIDEND NEUTRAL STOCK FUTURE",
  #     "marketSector"=>"Equity",
  #     "shareClassFIGI"=>nil,
  #     "uniqueIDFutOpt"=>"IBMD=4 OC Equity",
  #     "securityType2"=>"Future",
  #     "securityDescription"=>"IBMD=4"},
  #    {"figi"=>"BBG00196W5Y0",
  #     "name"=>"Ibm",
  #     "ticker"=>"IBMD=3",
  #     "exchCode"=>"OC",
  #     "compositeFIGI"=>nil,
  #     "uniqueID"=>"EF12901854290074186860",
  #     "securityType"=>"DIVIDEND NEUTRAL STOCK FUTURE",
  #     "marketSector"=>"Equity",
  #     "shareClassFIGI"=>nil,
  #     "uniqueIDFutOpt"=>"IBMD=3 OC Equity",
  #     "securityType2"=>"Future",
  #     "securityDescription"=>"IBMD=3"},
  #    ...
```

Search and `#next`:
```ruby
r = client.search('ibm')
  #
  # grab the first "page" of results

r = r.next
  #
  # grab the next page of results

# ...
```


## license

MIT, see [LICENSE.txt](LICENSE.txt)

