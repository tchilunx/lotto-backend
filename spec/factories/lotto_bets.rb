FactoryBot.define do
  factory :lotto_bet do
    client { nil }
    client_wallet { nil }
    lotto_draw { nil }
    session { "MyString" }
    draw_date { "2025-11-20" }
    amount { "9.99" }
    status { "MyString" }
    bet_reference { "MyString" }
    numbers { 1 }
  end
end
