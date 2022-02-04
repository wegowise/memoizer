require 'rubygems'
require 'bundler/setup'
require 'date'
require 'memoizer'
require 'timecop'

RSpec.configure do |config|
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
