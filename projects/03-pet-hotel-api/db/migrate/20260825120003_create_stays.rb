class CreateStays < ActiveRecord::Migration[8.1]
  def change
    create_table :stays do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pet, null: false, foreign_key: true
      t.date :check_in, null: false
      t.date :check_out, null: false
      # Dinheiro em centavos (integer). Nunca Float.
      t.integer :nightly_rate_cents, null: false
      # 0 scheduled, 1 checked_in, 2 checked_out — ver Stay enum
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
