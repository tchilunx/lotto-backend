class ChangeEnumColumnsToInteger < ActiveRecord::Migration[8.1]
  def up
    # ClientWallet
    change_column :client_wallets, :wallet_type, :integer, using: "CASE WHEN wallet_type = 'primary_wallet' THEN 0 ELSE 0 END", default: 0

    # ClientOperation
    change_column :client_operations, :operation_type, :integer, using: "CASE WHEN operation_type = 'credit' THEN 0 WHEN operation_type = 'debit' THEN 1 WHEN operation_type = 'lock' THEN 2 WHEN operation_type = 'unlock' THEN 3 ELSE 0 END"
    change_column :client_operations, :status, :integer, using: "CASE WHEN status = 'pending' THEN 0 WHEN status = 'completed' THEN 1 WHEN status = 'failed' THEN 2 WHEN status = 'cancelled' THEN 3 ELSE 0 END"

    # ClientTopup
    change_column :client_topups, :status, :integer, using: "CASE WHEN status = 'pending' THEN 0 WHEN status = 'completed' THEN 1 WHEN status = 'failed' THEN 2 ELSE 0 END"

    # ServiceImoney
    change_column :service_imoneys, :status, :integer, using: "CASE WHEN status = 'pending' THEN 0 WHEN status = 'completed' THEN 1 WHEN status = 'failed' THEN 2 ELSE 0 END"

    # KycRequest
    change_column_default :kyc_requests, :status, nil
    change_column :kyc_requests, :status, :integer, using: "CASE WHEN status = 'pending' THEN 0 WHEN status = 'approved' THEN 1 WHEN status = 'rejected' THEN 2 ELSE 0 END", default: 0
    change_column_default :kyc_requests, :status, 0

    # LottoBet
    change_column_default :lotto_bets, :status, nil
    change_column :lotto_bets, :session, :integer, using: "CASE WHEN session = 'morning' THEN 0 WHEN session = 'evening' THEN 1 ELSE 0 END"
    change_column :lotto_bets, :status, :integer, using: "CASE WHEN status = 'pending' THEN 0 WHEN status = 'won' THEN 1 WHEN status = 'lost' THEN 2 WHEN status = 'cancelled' THEN 3 ELSE 0 END", default: 0
    change_column_default :lotto_bets, :status, 0

    # LottoDraw
    change_column_default :lotto_draws, :status, nil
    change_column :lotto_draws, :session, :integer, using: "CASE WHEN session = 'morning' THEN 0 WHEN session = 'evening' THEN 1 ELSE 0 END"
    change_column :lotto_draws, :status, :integer, using: "CASE WHEN status = 'pending' THEN 0 WHEN status = 'drawn' THEN 1 WHEN status = 'completed' THEN 2 ELSE 0 END", default: 0
    change_column_default :lotto_draws, :status, 0

    # LottoWin
    change_column_default :lotto_wins, :status, nil
    change_column :lotto_wins, :status, :integer, using: "CASE WHEN status = 'pending' THEN 0 WHEN status = 'credited' THEN 1 WHEN status = 'cancelled' THEN 2 ELSE 0 END", default: 0
    change_column_default :lotto_wins, :status, 0
  end

  def down
    # Revert is tricky because we lost the original strings, but we can map back
    change_column :client_wallets, :wallet_type, :string
    change_column :client_operations, :operation_type, :string
    change_column :client_operations, :status, :string
    change_column :client_topups, :status, :string
    change_column :service_imoneys, :status, :string
    change_column :kyc_requests, :status, :string
    change_column :lotto_bets, :session, :string
    change_column :lotto_bets, :status, :string
    change_column :lotto_draws, :session, :string
    change_column :lotto_draws, :status, :string
    change_column :lotto_wins, :status, :string
  end
end
