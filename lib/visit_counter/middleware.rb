# frozen_string_literal: true

module VisitCounter
  class Middleware
    RESULTS_PATH = '/visit_counter_results'
    USERNAME     = 'abc'
    PASSWORD     = 'def'

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      return results_page(env) if request.path_info == RESULTS_PATH

      record_visit(request)

      @app.call(env)
    end

    private

    def results_page(env)
      auth(results_response).call(env)
    end

    def results_response
      proc {
        Rack::Response.new.tap do |resp|
          resp['Content-Type'] = 'application/json; charset=UTF-8'
          resp.status          = 200
          resp.body            = [Visit.visit_report.to_json]
        end
      }
    end

    def record_visit(request)
      create_exact_visit if request.path_info == VisitCounter.configuration.exact_url
      create_regex_visit if request.path_info.match?(VisitCounter.configuration.regex_url)
    end

    def create_exact_visit
      Visit.new(url: VisitCounter.configuration.exact_url).save
    end

    def create_regex_visit
      Visit.new(url: VisitCounter.configuration.regex_url.source).save
    end

    def auth(response)
      Rack::Auth::Basic.new(response) do |username, password|
        username == USERNAME && password == PASSWORD
      end
    end
  end
end
