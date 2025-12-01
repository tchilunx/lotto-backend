class AddBalancesToClientWallets < ActiveRecord::Migration[8.1]
  def change
    add_column :client_wallets, :real_balance, :decimal, precision: 12, scale: 2, default: 0.0, null: false
    add_column :client_wallets, :theoretical_balance, :decimal, precision: 12, scale: 2, default: 0.0, null: false
  end
end
