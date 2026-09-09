# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :accounts do
      primary_key :id, type: :Bignum
      Integer :status, null: false, default: 2
      String :email, null: false
      index :email, unique: true
      String :password_hash
    end

    create_table :locais do
      primary_key :id
      String :name, null: false
    end

    create_table :eventos do
      primary_key :id
      String :title, null: false
      Time :starts_at
      String :venue
    end
  end
end
