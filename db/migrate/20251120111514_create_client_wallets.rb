class CreateClientWallets < ActiveRecord::Migration[8.1]
  def change
    create_table :client_wallets do |t|
      t.references :client, null: false, foreign_key: true
      t.string :wallet_type
      t.decimal :balance, precision: 12, scale: 2
      t.boolean :locked

      t.timestamps
    end
  end
end
