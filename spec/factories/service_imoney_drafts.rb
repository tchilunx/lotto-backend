FactoryBot.define do
  factory :service_imoney_draft do
    client { nil }
    amount { "9.99" }
    phone_number { "MyString" }
    draft_data { "" }
  end
end
