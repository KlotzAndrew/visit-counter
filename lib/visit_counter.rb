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

  def serialize_configuration
    {
      'db_url'    => configuration.db_url,
      'exact_url' => configuration.exact_url,
      'regex_url' => configuration.regex_url.source
    }
  end

  def start!
    require 'visit_counter/db'
    require 'visit_counter/repositories/visit'
  end
end
