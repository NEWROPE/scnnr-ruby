# frozen_string_literal: true

require 'bundler/setup'
require 'scnnr'
require 'webmock/rspec'
require 'rr'
require 'support/fixture'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.mock_with :rr

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
