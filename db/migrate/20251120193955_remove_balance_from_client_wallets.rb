class RemoveBalanceFromClientWallets < ActiveRecord::Migration[8.1]
  def change
    remove_column :client_wallets, :balance, :decimal
  end
end
