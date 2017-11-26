# frozen_string_literal: true

module VisitCounter
  class Visit < Sequel::Model(DB.connection[:visit_counter_visits])
    plugin :timestamps, force: true, update_on_create: true

    def validate
      super
      validates_presence [:url]
    end

    # rubocop:disable Metrics/MethodLength
    def self.visit_report
      query = <<~SQL
        SELECT url, date, count
        FROM   (SELECT Date_trunc('day', created_at::DATE) AS date,
                       Count(*),
                       url
                FROM   visit_counter_visits
                GROUP  BY DATE,
                          url
                ORDER  BY DATE,
                          url) AS url_visits
        GROUP  BY date,
                  url,
                  count
        ORDER  BY date DESC,
                  url ASC,
                  count
      SQL

      DB.connection[query].to_a
    end
  end
end
