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

  let(:results_path) { VisitCounter::Middleware::RESULTS_PATH }
  let(:username) { VisitCounter::Middleware::USERNAME }
  let(:password) { VisitCounter::Middleware::PASSWORD }

  it 'runs a server' do
    response = fetch_response('/')

    expect(response.code).to eq('200')
    expect(response.body).to eq('everything is awesome!')
  end

  it 'records an exact visit' do
    results_response = fetch_response(results_path, username, password)
    body = JSON.parse(results_response.body)
    expect(body).to eq([])

    results_response = fetch_response('/puppies')
    expect(results_response.body).to eq('everything is awesome!')

    results_response = fetch_response(results_path, username, password)
    body = JSON.parse(results_response.body)
    expect(body).to eq([{ 'url' => '/puppies', 'date' => Time.now.beginning_of_day.to_s, 'count' => 1 }])
  end

  it 'auth required for results' do
    results_response = fetch_response(results_path, 'bad user', 'bad pass')
    expect(results_response.code).to eq('401')
  end

  def fetch_response(path, username = nil, password = nil)
    uri = URI.parse("http://localhost:#{TestServer::PORT}#{path}")
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(username, password) if username && password

    Net::HTTP.new(uri.host, uri.port).request(request)
  end
end
