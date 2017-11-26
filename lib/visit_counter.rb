# frozen_string_literal: true

require 'visit_counter/version'
require 'visit_counter/middleware'
require 'visit_counter/configuration'

module VisitCounter
  module_function

  def configuration
    @configuration ||= Configuration.new
  end

  def configure
    yield configuration
    start!
  end

  def start!
    require 'visit_counter/db'
    require 'visit_counter/repositories/visit'
  end
end
