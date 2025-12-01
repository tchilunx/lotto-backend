class ServiceImoney < ApplicationRecord
  belongs_to :client

  enum :status, {
    pending: 0,
    completed: 1,
    failed: 2
  }, default: :pending

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :reference, presence: true, uniqueness: true
  validates :phone_number, presence: true
end
