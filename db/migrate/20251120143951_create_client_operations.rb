class CreateClientOperations < ActiveRecord::Migration[8.1]
  def change
    create_table :client_operations do |t|
      t.references :client, null: false, foreign_key: true
      t.references :client_wallet, null: false, foreign_key: true
      t.string :operation_type, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.decimal :balance_before, precision: 12, scale: 2, null: false
      t.decimal :balance_after, precision: 12, scale: 2, null: false
      t.string :reference, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
