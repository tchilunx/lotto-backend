class LottoWin < ApplicationRecord
  belongs_to :lotto_bet
  belongs_to :lotto_draw

  enum :status, {
    pending: 0,
    credited: 1,
    cancelled: 2
  }, default: :pending
end
