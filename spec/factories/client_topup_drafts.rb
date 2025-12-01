FactoryBot.define do
  factory :client_topup_draft do
    client { nil }
    amount { "9.99" }
    payment_method { "MyString" }
    draft_data { "" }
  end
end
