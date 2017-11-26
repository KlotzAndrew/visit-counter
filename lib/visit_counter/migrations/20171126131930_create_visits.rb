# frozen_string_literal: true

Sequel.migration do
  change do
    run 'create extension if not exists "uuid-ossp"'

    create_table :visit_counter_visits do
      primary_key :id, :uuid, default: Sequel.function(:uuid_generate_v4)
      column :url, String, null: false, text: true

      column :created_at, Time, null: false
      column :updated_at, Time, null: false
    end
  end
end
