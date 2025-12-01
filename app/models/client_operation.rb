class ClientOperation < ApplicationRecord
  belongs_to :client
  belongs_to :client_wallet

  enum :operation_type, {
    credit: 0,
    debit: 1,
    lock: 2,
    unlock: 3
  }, prefix: :operation

  enum :status, {
    pending: 0,
    completed: 1,
    failed: 2,
    cancelled: 3
  }, default: :pending

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reference, presence: true, uniqueness: true
end
