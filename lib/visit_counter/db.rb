# frozen_string_literal: true

require 'sequel'
require 'logger'

extensions = [:migration]

extensions.each { |ext| Sequel.extension(ext) }

Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :timestamps

module VisitCounter
  class DB
    class << self
      def connection
        @connection ||= begin
          db = Sequel.connect(VisitCounter.configuration.db_url, max_connections: 20)
          db.loggers << logger
          db.extension :pg_json
          db
        end
      end

      def run_migrations(db_url)
        Sequel.connect(db_url) do |db|
          db.logger = logger
          dir = File.join(__dir__, 'migrations')
          Sequel::TimestampMigrator.run(db, dir, {})
        end
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
    end
  end
end
