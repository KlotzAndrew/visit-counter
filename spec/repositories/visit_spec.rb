# frozen_string_literal: true

require 'spec_helper'

module VisitCounter
  RSpec.describe 'Visit' do
    before { setup_db }
    after { clear_db }

    it 'returns groups visits' do
      visit_configs = [
        { url: '/', date: '017-11-26 00:00:00', count: 2 },
        { url: '/', date: '017-11-25 00:00:00', count: 3 },
        { url: '/', date: '017-11-24 00:00:00', count: 4 },
        { url: '/dogs', date: '017-11-26 00:00:00', count: 1 },
        { url: '/dogs', date: '017-11-24 00:00:00', count: 3 },
        { url: '/cats', date: '017-11-25 00:00:00', count: 2 },
        { url: '/cats', date: '017-11-24 00:00:00', count: 1 }
      ]

      visit_configs.each do |visit_config|
        visit_config[:count].times do
          Visit.new.tap do |_visit|
            visit = Visit.new(url: visit_config[:url]).save
            visit.created_at = Time.parse(visit_config[:date])
            visit.save
          end
        end
      end

      report = Visit.visit_report
      report.each { |r| r[:date] = r[:date].to_s }
      expect(report).to eq(
        [
          { url: '/', date: '0017-11-26 00:00:00 -0500', count: 2 },
          { url: '/dogs', date: '0017-11-26 00:00:00 -0500', count: 1 },
          { url: '/', date: '0017-11-25 00:00:00 -0500', count: 3 },
          { url: '/cats', date: '0017-11-25 00:00:00 -0500', count: 2 },
          { url: '/', date: '0017-11-24 00:00:00 -0500', count: 4 },
          { url: '/cats', date: '0017-11-24 00:00:00 -0500', count: 1 },
          { url: '/dogs', date: '0017-11-24 00:00:00 -0500', count: 3 }
        ]
      )
    end

    it 'returns groups visits in csv' do
      visit_configs = [
        { url: '/', date: '017-11-26 00:00:00', count: 2 },
        { url: '/', date: '017-11-25 00:00:00', count: 3 },
        { url: '/', date: '017-11-24 00:00:00', count: 4 },
        { url: '/dogs', date: '017-11-26 00:00:00', count: 1 },
        { url: '/dogs', date: '017-11-24 00:00:00', count: 3 },
        { url: '/cats', date: '017-11-25 00:00:00', count: 2 },
        { url: '/cats', date: '017-11-24 00:00:00', count: 1 }
      ]

      visit_configs.each do |visit_config|
        visit_config[:count].times do
          Visit.new.tap do |_visit|
            visit = Visit.new(url: visit_config[:url]).save
            visit.created_at = Time.parse(visit_config[:date])
            visit.save
          end
        end
      end

      report = Visit.visit_report_csv
      parsed_report = CSV.parse(report)

      expect(parsed_report).to eq(
        [
          ['url', 'date', 'count'],
          ['/', '0017-11-26 00:00:00 -0500', '2'],
          ['/dogs', '0017-11-26 00:00:00 -0500', '1'],
          ['/', '0017-11-25 00:00:00 -0500', '3'],
          ['/cats', '0017-11-25 00:00:00 -0500', '2'],
          ['/', '0017-11-24 00:00:00 -0500', '4'],
          ['/cats', '0017-11-24 00:00:00 -0500', '1'],
          ['/dogs', '0017-11-24 00:00:00 -0500', '3']
        ]
      )
    end
  end
end
