class LottoBet < ApplicationRecord
  belongs_to :client
  belongs_to :client_wallet
  belongs_to :lotto_draw, optional: true
  has_one :lotto_win

  enum :session, { morning: 0, evening: 1 }
  enum :status, { 
    pending: 0, 
    won: 1, 
    lost: 2, 
    cancelled: 3 
  }, default: :pending
  
  validates :numbers, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :bet_reference, presence: true, uniqueness: true
  
  validate :validate_numbers_count
  validate :validate_numbers_range

  private

  def validate_numbers_count
    errors.add(:numbers, "doit contenir exactement 5 numéros") if numbers.nil? || numbers.length != 5
  end

  def validate_numbers_range
    return if numbers.nil?
    errors.add(:numbers, "doivent être entre 1 et 90") if numbers.any? { |n| n < 1 || n > 90 }
    errors.add(:numbers, "doivent être uniques") if numbers.uniq.length != numbers.length
  end
end
