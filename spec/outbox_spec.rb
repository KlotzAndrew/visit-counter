# frozen_string_literal: true

require 'spec_helper'

module VisitCounter
  RSpec.describe Outbox do
    let(:subject) { described_class }

    before { setup_db }
    after { clear_db }

    it 'enqueues and dequeues' do
      subject.start!

      url = '/doggo'
      expect(Visit.where(url: url).count).to eq(0)

      subject.enqueue(url)
      integration_wait!

      expect(Visit.where(url: url).count).to eq(1)
    end
  end
end
