FactoryBot.define do
  factory :lotto_draw do
    session { "MyString" }
    draw_date { "2025-11-20" }
    drawn_at { "2025-11-20 15:48:44" }
    status { "MyString" }
    numbers { 1 }
  end
end
