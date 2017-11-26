# frozen_string_literal: true

require 'rack'
require 'visit_counter'

App = proc { |_env| ['200', {}, ['everything is awesome!']] }

VisitCounter.configure do |config|
  config.db_url    = 'postgresql://postgres:@0.0.0.0:5432'
  config.exact_url = '/puppies'
  config.regex_url = /^\/pup.*/
end

use VisitCounter::Middleware
run App
