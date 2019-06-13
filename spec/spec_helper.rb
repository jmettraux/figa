
#
# Specifying figa
#
# Thu Jun 13 15:29:09 JST 2019
#

require 'pp'
#require 'ostruct'

require 'figa'


module Helpers

  def jruby?; !! RUBY_PLATFORM.match(/java/); end
  def windows?; Gem.win_platform?; end
end # Helpers


RSpec.configure do |c|

  c.alias_example_to(:they)
  c.alias_example_to(:so)
  c.include(Helpers)
end

