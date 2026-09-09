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

    create_table :lotes do
      primary_key :id
      foreign_key :evento_id, :eventos, null: false
      String :name, null: false
      Integer :price_cents, null: false
      Integer :quantity, null: false
      Time :sales_starts_at
      Time :sales_ends_at
    end

    create_table :pedidos do
      primary_key :id
      foreign_key :account_id, :accounts, null: false, type: :Bignum
      foreign_key :lote_id, :lotes, null: false
      Integer :quantity, null: false
      Integer :total_cents, null: false
      String :status, null: false
      Time :reserved_until
      Time :created_at, null: false
    end

    create_table :webhook_events do
      primary_key :id
      String :idempotency_key, null: false, unique: true
      Integer :pedido_id
      String :status
      String :payload, text: true
      Time :created_at, null: false
    end

    create_table :jwt_denylist do
      primary_key :id
      String :fingerprint, null: false, unique: true
      Time :revoked_at, null: false
    end
  end
end
