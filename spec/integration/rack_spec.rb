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
  let(:results_path_csv) { VisitCounter::Middleware::RESULTS_PATH_CSV }
  let(:configure_path) { VisitCounter::Middleware::CONFIGURE_PATH }
  let(:username) { VisitCounter::Middleware::USERNAME }
  let(:password) { VisitCounter::Middleware::PASSWORD }
  let(:config_data) do
    { 'exact_url=' => '/dogs_and_cats', 'regex_url=' => '/dogs_and_cats.*' }
  end

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
    expect(body).to eq(
      [
        { 'url' => '/puppies', 'date' => Time.now.beginning_of_day.to_s, 'count' => 1 },
        { 'url' => '^/pup.*', 'date' => Time.now.beginning_of_day.to_s, 'count' => 1 }
      ]
    )

    results_response_csv = fetch_response(results_path_csv, username, password)
    body = CSV.parse(results_response_csv.body)
    expect(body).to eq(
      [
        ['url', 'date', 'count'],
        ['/puppies', '2017-11-26 00:00:00 -0500', '1'],
        ['^/pup.*', '2017-11-26 00:00:00 -0500', '1']
      ]
    )
  end

  it 'auth required for results' do
    results_response = fetch_response(results_path, 'bad user', 'bad pass')
    expect(results_response.code).to eq('401')
  end

  it 'auth required for results csv' do
    results_response = fetch_response(results_path, 'bad user', 'bad pass')
    expect(results_response.code).to eq('401')
  end

  it 'auth required for configure' do
    results_response = post_data(configure_path, config_data, 'bad user', 'bad pass')
    expect(results_response.code).to eq('401')
  end

  it 'updates config' do
    results_response = post_data(configure_path, config_data, username, password)
    expect(results_response.code).to eq('200')
    body = JSON.parse(results_response.body)

    expect(body['exact_url']).to eq(config_data['exact_url='])
    expect(body['regex_url']).to eq(config_data['regex_url='])
  end

  def fetch_response(path, username = nil, password = nil)
    uri     = URI.parse("http://localhost:#{TestServer::PORT}#{path}")
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(username, password) if username && password

    Net::HTTP.new(uri.host, uri.port).request(request)
  end

  def post_data(path, data = {}, username = nil, password = nil)
    uri     = URI.parse("http://localhost:#{TestServer::PORT}#{path}")
    request = Net::HTTP::Post.new(uri.request_uri)
    request.basic_auth(username, password) if username && password
    request.body = data.to_json

    Net::HTTP.new(uri.host, uri.port).request(request)
  end
end
