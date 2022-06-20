# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  minimum_coverage 95
  add_filter '/spec/'
end

require_relative '../autoload'
require 'rack/test'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.include Rack::Test::Methods

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
