class KycRequest < ApplicationRecord
  belongs_to :client
  has_many_attached :documents

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }, default: :pending

  validates :document_type, presence: true
  validates :document_number, presence: true
end
