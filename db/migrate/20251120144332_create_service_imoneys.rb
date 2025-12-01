class CreateServiceImoneys < ActiveRecord::Migration[8.1]
  def change
    create_table :service_imoneys do |t|
      t.references :client, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :phone_number, null: false
      t.string :status, null: false
      t.string :reference, null: false
      t.string :external_reference

      t.timestamps
    end
    add_index :service_imoneys, :reference, unique: true
  end
end
