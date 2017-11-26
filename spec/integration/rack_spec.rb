# frozen_string_literal: true

require 'spec_helper'

require 'net/http'

RSpec.describe 'integration' do
  before(:context) do
    setup_db
    TestServer.start
  end

  after(:context) { TestServer.stop }

  it 'runs a server' do
    response = fetch_response('/')

    expect(response.code).to eq('200')
    expect(response.body).to eq('everything is awesome!')
  end

  def fetch_response(path)
    uri = URI.parse("http://localhost:#{TestServer::PORT}#{path}")
    request = Net::HTTP::Get.new(uri.request_uri)

    Net::HTTP.new(uri.host, uri.port).request(request)
  end
end
