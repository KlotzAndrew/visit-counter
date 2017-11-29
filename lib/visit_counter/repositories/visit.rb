# frozen_string_literal: true

require 'csv'

module VisitCounter
  class Visit < Sequel::Model(DB.connection[:visit_counter_visits])
    plugin :timestamps, force: true, update_on_create: true

    def validate
      super
      validates_presence [:url]
    end

    def self.visit_report
      DB.connection[report_sql].to_a
    end

    def self.visit_report_csv
      query = <<~SQL
        COPY (#{report_sql}) to STDOUT (format CSV)
      SQL

      csv = ['url', 'date', 'count'].to_csv
      csv << copy_pg_data(query)
    end

    def self.report_sql
      <<~SQL
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
    end

    # NOTE: PR this when I get a chance
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Performance/UnfreezeString
    # rubocop:disable Lint/RescueWithoutErrorClass
    # rubocop:disable Style/StringLiterals
    # rubocop:disable Lint/AssignmentInCondition
    def self.copy_pg_data(query)
      DB.connection.synchronize do |conn|
        conn.execute(query) do
          begin
            if block_given?
              while buf = conn.get_copy_data
                yield buf
              end
              nil
            else
              b = String.new
              b << buf while buf = conn.get_copy_data
              b
            end
          rescue => e
            puts e
          ensure
            if buf && !e
              raise "disconnecting as a partial COPY may leave the connection in an unusable state"
            end
          end
        end
      end
    end
  end
end
