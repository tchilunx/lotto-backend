FactoryBot.define do
  factory :client_topup do
    client { nil }
    amount { "9.99" }
    payment_method { "MyString" }
    status { "MyString" }
    reference { "MyString" }
    external_reference { "MyString" }
  end
end
