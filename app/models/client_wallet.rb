class ClientWallet < ApplicationRecord
  belongs_to :client

  enum :wallet_type, { primary_wallet: 0 }, default: :primary_wallet
end
