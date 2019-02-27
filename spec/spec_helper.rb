require 'date'
require 'timecop'
require 'memoized'

RSpec.configure do |config|
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
