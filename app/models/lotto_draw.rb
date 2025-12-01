class LottoDraw < ApplicationRecord
  has_many :lotto_bets
  has_many :lotto_wins

  enum :session, { morning: 0, evening: 1 }
  enum :status, { 
    pending: 0, 
    drawn: 1, 
    completed: 2 
  }, default: :pending

  validates :draw_date, presence: true
  validates :session, presence: true
  validates :numbers, presence: true, if: :drawn?
end
