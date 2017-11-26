# frozen_string_literal: true

require 'rack'
require 'visit_counter'

App = proc { |_env| ['200', {}, ['everything is awesome!']] }

use VisitCounter::Middleware
run App
