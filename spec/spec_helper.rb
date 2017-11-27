# frozen_string_literal: true

require 'bundler/setup'
require 'visit_counter'
require 'pry'

require_relative 'integration/test_server'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def setup_db
  VisitCounter.configure do |config|
    config.db_url = 'postgresql://postgres:@0.0.0.0:5432'
  end
end

def clear_db
  VisitCounter::Visit.dataset.delete
end

def integration_wait!
  sleep VisitCounter::Outbox::GIL_SLEEP * 2
end
