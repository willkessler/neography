require 'rspec'
require 'timecop'

# Load Deja lib
CURRENT_DIR = File.dirname(__FILE__)
$: << File.expand_path(CURRENT_DIR + '/../lib')
require 'factory_girl'
require 'deja'
include Deja

require File.dirname(__FILE__) + "/factories"

def generate_text(length=8)
  chars = 'abcdefghjkmnpqrstuvwxyz'
  key = ''
  length.times { |i| key << chars[rand(chars.length)] }
  key
end
RSpec.configure do |config|
  # Before all specs, for each spec file
  config.before(:all) { SpecHelper.truncate }
end

class SpecHelper
  def self.truncate
    # Deja.neo.execute_query("START n=node(*) MATCH n-[r?]->() WHERE ID(n) <> 0 DELETE r DELETE n")
  end
end
