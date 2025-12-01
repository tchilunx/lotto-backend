class CreateClientTopups < ActiveRecord::Migration[8.1]
  def change
    create_table :client_topups do |t|
      t.references :client, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :payment_method, null: false
      t.string :status, null: false
      t.string :reference, null: false
      t.string :external_reference

      t.timestamps
    end
    add_index :client_topups, :reference, unique: true
  end
end
