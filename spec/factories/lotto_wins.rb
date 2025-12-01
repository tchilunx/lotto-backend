FactoryBot.define do
  factory :lotto_win do
    lotto_bet { nil }
    lotto_draw { nil }
    win_amount { "9.99" }
    matched_numbers { 1 }
    status { "MyString" }
    credited_at { "2025-11-20 15:49:05" }
  end
end
