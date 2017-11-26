# frozen_string_literal: true

module VisitCounter
  class Middleware
    RESULTS_PATH = '/visit_counter_results'

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      return results_page if request.path_info == RESULTS_PATH

      record_visit(request)

      @app.call(env)
    end

    private

    def results_page
      Rack::Response.new.tap do |resp|
        resp['Content-Type'] = 'application/json; charset=UTF-8'
        resp.status          = 200
        resp.body            = [Visit.visit_report.to_json]
      end
    end

    def record_visit(request)
      create_exact_visit if request.path_info == VisitCounter.configuration.exact_url
    end

    def create_exact_visit
      Visit.new(url: VisitCounter.configuration.exact_url).save
    end
  end
end
