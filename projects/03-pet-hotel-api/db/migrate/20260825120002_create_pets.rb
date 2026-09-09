class CreatePets < ActiveRecord::Migration[8.1]
  def change
    create_table :pets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :owner, null: false, foreign_key: true
      t.string :name, null: false
      t.string :species, null: false

      t.timestamps
    end
  end
end
