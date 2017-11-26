# frozen_string_literal: true

module VisitCounter
  class Configuration
    attr_accessor :db_url
    attr_accessor :exact_url
    attr_accessor :regex_url
  end
end
