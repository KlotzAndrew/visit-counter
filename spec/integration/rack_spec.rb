# frozen_string_literal: true

require 'spec_helper'
require 'active_support/time'

require 'net/http'

RSpec.describe 'integration' do
  before(:context) do
    setup_db
    TestServer.start
  end

  after(:context) { TestServer.stop }

  after { clear_db }

  it 'runs a server' do
    response = fetch_response('/')

    expect(response.code).to eq('200')
    expect(response.body).to eq('everything is awesome!')
  end

  it 'records an exact visit' do
    results_response = fetch_response(VisitCounter::Middleware::RESULTS_PATH)
    body = JSON.parse(results_response.body)
    expect(body).to eq([])

    results_response = fetch_response('/puppies')
    expect(results_response.body).to eq('everything is awesome!')

    results_response = fetch_response(VisitCounter::Middleware::RESULTS_PATH)
    body = JSON.parse(results_response.body)
    expect(body).to eq([{ 'url' => '/puppies', 'date' => Time.now.beginning_of_day.to_s, 'count' => 1 }])
  end

  def fetch_response(path)
    uri = URI.parse("http://localhost:#{TestServer::PORT}#{path}")
    request = Net::HTTP::Get.new(uri.request_uri)

    Net::HTTP.new(uri.host, uri.port).request(request)
  end
end
