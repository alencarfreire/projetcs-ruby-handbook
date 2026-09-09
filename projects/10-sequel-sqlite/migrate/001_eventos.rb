# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :eventos do
      primary_key :id
      String :title, null: false
      Time :starts_at
      String :venue
    end
  end
end
