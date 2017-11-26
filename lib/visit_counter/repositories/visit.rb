# frozen_string_literal: true

module VisitCounter
  class Visit < Sequel::Model(DB.connection[:visit_counter_visits])
    plugin :timestamps, force: true, update_on_create: true

    def validate
      super
      validates_presence [:url]
    end
  end
end
