# frozen_string_literal: true

module VisitCounter
  class Middleware
    RESULTS_PATH     = '/visit_counter_results'
    RESULTS_PATH_CSV = '/visit_counter_results/csv'
    CONFIGURE_PATH   = '/visit_counter_results/configure'
    USERNAME         = 'abc'
    PASSWORD         = 'def'

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      return authorize(results_response, env) if results?(request)
      return authorize(results_response_csv, env) if results_csv?(request)
      return authorize(configure(request), env) if configure?(request)

      record_visit(request)

      @app.call(env)
    end

    private

    def results?(request)
      request.path_info == RESULTS_PATH
    end

    def results_csv?(request)
      request.path_info == RESULTS_PATH_CSV
    end

    def configure?(request)
      request.path_info == CONFIGURE_PATH && request.post?
    end

    def results_response
      proc {
        Rack::Response.new.tap do |resp|
          resp['Content-Type'] = 'application/json'
          resp.status          = 200
          resp.body            = [Visit.visit_report.to_json]
        end
      }
    end

    def results_response_csv
      proc {
        Rack::Response.new.tap do |resp|
          resp['Content-Type'] = 'text/csv; charset=UTF-8'
          resp.status          = 200
          resp.body            = [Visit.visit_report_csv]
        end
      }
    end

    def configure(request)
      proc {
        body = request.body.read
        data = JSON.parse(body)
        update_configuration(data)

        Rack::Response.new.tap do |resp|
          resp['Content-Type'] = 'application/json'
          resp.status          = 200
          resp.body            = [VisitCounter.serialize_configuration.to_json]
        end
      }
    end

    def update_configuration(data)
      data.each do |k, v|
        if k == 'regex_url=' && v.class != Regexp
          regex = Regexp.new(v)
          VisitCounter.configuration.public_send(k, regex)
        else
          VisitCounter.configuration.public_send(k, v)
        end
      end
    end

    def record_visit(request)
      create_exact_visit if request.path_info == VisitCounter.configuration.exact_url
      create_regex_visit if request.path_info.match?(VisitCounter.configuration.regex_url)
    end

    def create_exact_visit
      # Visit.new(url: VisitCounter.configuration.exact_url).save
      Outbox.enqueue(VisitCounter.configuration.exact_url)
    end

    def create_regex_visit
      # Visit.new(url: VisitCounter.configuration.regex_url.source).save
      Outbox.enqueue(VisitCounter.configuration.regex_url.source)
    end

    def authorize(page, env)
      auth = Rack::Auth::Basic.new(page) do |username, password|
        username == USERNAME && password == PASSWORD
      end

      auth.call(env)
    end
  end
end
